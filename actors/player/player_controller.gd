extends CharacterBody3D
# Handles responses to player input by applying movement and triggering interactions with the game world.

const CameraViewbob := preload("camera_viewbob.gd")
const InputDirection := preload("input_direction.gd")

const MAX_SPEED := 5.0
const SPRINT_SPEED := 8.0
const MOVE_ACCEL := 1.75
const MOVE_DEACCEL := 8.0  # TODO: Rename or give description here
const MAX_SLOPE_ANGLE := deg_to_rad(40.0)
const MAX_CAMERA_X_DEGREE := 70.0
const FLOOR_SNAP_LENGTH := .2
const MIN_FLOOR_Y_VELOCITY := -0.5

@export var jump_force := 20 # (int, 10, 20)

var god_mode := false
var playable := true : set = set_playable
var mouse_look_sensitivity := 0.1
var joy_look_sensitivity := 3.0
#var velocity := Vector3.ZERO
var force_capture_mouse_motion := false
var _turn_amount := 0.0  # TODO: This is re-initialized every tick - delete if possible
var _camera_turned_this_update := false  # TODO: can we eliminate this state?
var sprinting := false
var jumping := false
var flat_velocity: float

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var _camera := $RotationHelper/Camera3D as Camera3D
@onready var _camera_viewbob := $RotationHelper/Camera3D as CameraViewbob
@onready var _rotation_helper := $RotationHelper as Node3D
@onready var _input_direction := $InputDirection as InputDirection
@onready var _interact_raycast := $RotationHelper/InteractRaycast
@onready var _footstep_manager := $FootstepManager


func _ready() -> void:
	_debug_setup()
	# warning-ignore-all:return_value_discarded
	SignalManager.connect("player_playable_changed",Callable(self,"_on_playable_changed"))
	_interact_raycast.set_current_collider(null)


func _input(event: InputEvent):
	if can_capture_mouse_motion() and event is InputEventMouseMotion:
		_turn_camera(-(event as InputEventMouseMotion).relative * self.mouse_look_sensitivity)
	
	
	
	if playable:
		if event.is_action_pressed("pause"):
			SignalManager.emit_signal("pause_toggled")
		elif event.is_action_pressed("zoom_camera"):
			_camera.zoom = _camera.FOV_IN
		elif event.is_action_released("zoom_camera"):
			_camera.zoom = _camera.DEFAULT_FOV
	
	if event.is_action_pressed("sprint"):
		sprinting = true
		_camera.zoom = _camera.FOV_OUT
	elif event.is_action_released("sprint"):
		sprinting = false
		_camera.zoom = _camera.DEFAULT_FOV


func _physics_process(delta: float):
	var camera_rotation := -self._input_direction.get_look_direction() * joy_look_sensitivity
	
	if camera_rotation != Vector2.ZERO:
		_turn_camera(camera_rotation)
	
	if !playable:
		self.velocity = Vector3.ZERO
		return
	
	var input_move_vector := self._input_direction.get_move_direction()
	
	var previous_velocity := self.velocity
	self.velocity = _process_velocity(
		delta, self.velocity, _get_walk_direction(self._camera.get_global_transform(), input_move_vector)
	)

	# Don't shoot up ramps
	if self.velocity.y > 0 and self.velocity.y > previous_velocity.y and not jumping:
		self.velocity.y = max(0, previous_velocity.y)

	var is_walking := input_move_vector.length_squared() > 0

	self._camera_viewbob.update_transform(delta, is_walking, self._turn_amount, input_move_vector.x, sprinting)

	# TODO: what's happening here?
	if !_camera_turned_this_update:
		_turn_amount = 0
	_camera_turned_this_update = false


func set_playable(new_playable: bool) -> void:
	playable = new_playable
	_interact_raycast.set_enabled(playable)
	
	if playable:
		return
	
	velocity = Vector3.ZERO
	_camera.zoom = _camera.DEFAULT_FOV


func get_rotation_helper_x_rotation() -> float:
	return self._rotation_helper.rotation_degrees.x


func get_input_direction() -> InputDirection:
	return self._input_direction


func can_capture_mouse_motion() -> bool:
	return true if self.force_capture_mouse_motion else Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED


# Calculates and applies velocity to physics body based checked input, returning the new velocity.
# TODO: "calculates AND applies" - the calculating can be made fully static, move the applying elsewhere
func _process_velocity(delta: float, velocity: Vector3, input_direction: Vector3) -> Vector3:
	input_direction.y = 0
	velocity.y -= delta * self.gravity
	var h_vel := Vector3(velocity.x, 0, velocity.z)

	input_direction = input_direction.normalized()
	var accel := MOVE_ACCEL if input_direction.dot(h_vel) > 0.0 else MOVE_DEACCEL

	var target
	if sprinting:
		target = input_direction * SPRINT_SPEED
	else:
		target = input_direction * MAX_SPEED
		
	h_vel = h_vel.lerp(target, accel * delta)

	# Reduce sliding up/down ramps when walking
	# https://github.com/godotengine/godot/issues/34117
	if !input_direction.dot(h_vel) > 0:
		if h_vel.x < 1 && h_vel.x > -1:
			h_vel.x = 0
		if h_vel.z < 1 && h_vel.z > -1:
			h_vel.z = 0

	var is_on_floor := is_on_floor()

	if is_on_floor:
		jumping = false
		if velocity.y < MIN_FLOOR_Y_VELOCITY:
			velocity.y = MIN_FLOOR_Y_VELOCITY
		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_force
			jumping = true
	
	velocity.x = h_vel.x
	velocity.z = h_vel.z
	
	var _snap
	if not jumping and is_on_floor():
		_snap = -get_floor_normal() * FLOOR_SNAP_LENGTH
	else:
		_snap = Vector3.ZERO
	
	flat_velocity = velocity.x + velocity.z
	
	return move_and_slide_with_snap(
		velocity,
#		snap,
		-get_floor_normal() * FLOOR_SNAP_LENGTH if is_on_floor else Vector3.ZERO,
		Vector3.UP,
		true,
		1,
		MAX_SLOPE_ANGLE
	)


# Basis vectors are already normalized.
static func _get_walk_direction(camera_transform: Transform3D, input_direction: Vector2) -> Vector3:
	return (-camera_transform.basis.z * -input_direction.y) + (camera_transform.basis.x * input_direction.x)


# Turns the player's Y rotation by `amount.y`, and the camera's X rotation by `amount.x`.
# X rotation is clamp by `MAX_CAMERA_X_DEGREE`.
func _turn_camera(amount: Vector2):
	self._rotation_helper.rotation_degrees.x = clamp(
		self._rotation_helper.rotation_degrees.x + amount.y, -MAX_CAMERA_X_DEGREE, MAX_CAMERA_X_DEGREE
	)
	var y_turn := deg_to_rad(amount.x)
	self.rotate_y(y_turn)
	self._turn_amount = -y_turn
	self._camera_turned_this_update = true


func _debug_setup():
	var debugCat = DebugMenu.add_category("PlayerInfo")
	DebugMenu.add_option(debugCat, "Position" , _debug_get_position)
	DebugMenu.add_option(debugCat, "God mode toggle" , _debug_toggle_god_mode)
	DebugMenu.add_option(debugCat, "Unlock all weapons" , _debug_unlock_all_weapons)


func _debug_get_position():
	print(transform.origin)


func _debug_toggle_god_mode():
	god_mode = !god_mode
	print("GodMode: " + str(god_mode))


func _debug_unlock_all_weapons():
	print("You got all them weapons.")


func _on_playable_changed(new_playable: bool) -> void:
	set_playable(new_playable)
	
	
	
#	if playable:
#		_interact_raycast.enable()
#	else:
#		_interact_raycast.disable()
	
#	set_physics_process(playable)
