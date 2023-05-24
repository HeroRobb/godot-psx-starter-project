class_name PlayerTopDown
extends TopDownActor


const CAMERA_ANGULAR_ACCELERATION = 4.0
const FLASH_TIME: float = 1.0

@export var _camera_path: NodePath

var playable := true
var just_died := false : set = set_just_died

#var _suit: Suit = null
var _last_known_ground_position: Vector3
var _show_souls := false : set = set_show_souls
var _paused := false : set = set_paused
var _camera_position: int = DIRECTIONS.BOTTOM
var _current_anim: int = -1
var _zoom_level: int = 0
var _flash_amount := 0
var _invincible := false : get = get_invincible, set = set_invincible
var _permanent_invincibility := false : set = set_permanent_invincibility
var _collision_enabled := true
var _camera: Camera3D

@onready var _character_mesh := $MeshContainer/EngineerFemaleYoung
@onready var _mesh_component: MeshComponent = $MeshComponent
@onready var _movement_component: MovementComponent = $MovementComponent
@onready var _health_component: HealthComponent = $HealthComponent
@onready var _hurtbox_component: HurtboxComponent = $HurtboxComponent
@onready var _last_ground_position_timer := $LastGroundPositionTimer
@onready var _debug_timer := $DebugTimer
@onready var _orbit_point := $OrbitPoint
@onready var _camera_positions := {
	DIRECTIONS.TOP: $CameraPositions/TopPosition,
	DIRECTIONS.RIGHT: $CameraPositions/RightPosition,
	DIRECTIONS.BOTTOM: $CameraPositions/BottomPosition,
	DIRECTIONS.LEFT: $CameraPositions/LeftPosition,
}


func _ready() -> void:
	_camera = get_node_or_null(_camera_path)
	assert(_camera, "No player camera found.")
	_camera_positions[DIRECTIONS.BOTTOM].transform.origin -= Vector3(0, -0.5, 0)
	_connect_signals()
	_debug_setup()
	_update_last_known_ground_position()
	_health_component.update_health()


func _process(delta: float) -> void:
	$OrbitPoint.rotate_y(3 * delta)
	if not playable:
		return
	_get_move_input()


func _physics_process(delta: float) -> void:
	if not _paused:
		var move_target: Vector3 = Vector3(global_position.x + direction.x, global_position.y, global_position.z + direction.y)
		_movement_component.move_to(move_target, delta)
	
	_update_camera_rotation(delta)


func _input(event: InputEvent) -> void:
	if not playable:
		return
	
#	if event.is_action_pressed("open_inventory"):
#		if _paused:
#			SignalManager.emit_signal("game_unpaused")
#		else:
#			SignalManager.emit_signal("game_paused")
#
#		SignalManager.emit_signal("inventory_ui_visibility_changed", _paused)
		
	if _paused:
		return
		
#	if event.is_action_pressed("attack"):
#		attack()
		
	elif event.is_action_pressed("rotate_camera_right"):
		_rotate_camera_right()
		
	elif event.is_action_pressed("rotate_camera_left"):
		_rotate_camera_left()


func attack() -> void:
	velocity = Vector3.ZERO
	_current_anim = _character_mesh.play_anim(Global.HUMANOID_ANIMATIONS.MELEE)


func set_mesh_rotation(new_mesh_rotation: Vector3) -> void:
	_mesh_container.rotation = new_mesh_rotation


func set_camera_position(new_camera_position: int) -> void:
	if new_camera_position >= _camera_positions.size():
		_camera_position = 0
	elif new_camera_position < 0:
		_camera_position = _camera_positions.size() - 1
	else:
		_camera_position = new_camera_position


func take_hit() -> void:
	if _health_component.invincible:
		return
	
	velocity = Vector3.ZERO
	SoundManager.play_sfx(Global.SFX.BLIP, randf_range(1.1, 1.3))
	_health_component.invincible = true
	SignalManager.set_delayed.emit(_health_component, "invincible", false, 1.0)
	SignalManager.screenshake_requested.emit()
	_mesh_component.flash(FLASH_TIME)


func die() -> void:
	just_died = true
	
	SignalManager.player_died.emit()
#	_stop_flash(true)
#	set_invincible(true)


func get_camera_3d() -> Camera3D:
	return _camera


func set_invincible(new_invincible: bool) -> void:
	if _permanent_invincibility:
		_invincible = true
		return
	
	_invincible = new_invincible


func get_invincible() -> bool:
	return _invincible


func set_permanent_invincibility(new_permanent_invincibility: bool) -> void:
	_permanent_invincibility = new_permanent_invincibility
	_invincible = _permanent_invincibility


func set_show_souls(new_show_souls: bool) -> void:
	_show_souls = new_show_souls
	
	_orbit_point.visible = _show_souls


## This should only be called by the GameStateSaver when the player is loaded
## in after dying. It will prevent an infinite loop of having the
## GameStateSaver restore the player's health to 0 and reloading the scene.
func set_just_died(new_just_died: bool) -> void:
#	if new_just_died:
#		fully_heal()
	
	just_died = new_just_died


func set_paused(new_paused: bool) -> void:
	_paused = new_paused
	
#	if _paused:
#		_character_mesh.play_anim(Global.HUMANOID_ANIMATIONS.IDLE)


func return_to_last_known_ground_position(damage_amount: int = 0) -> void:
	global_position = _last_known_ground_position
#	_health_component.take_damage(damage_amount)


func _play_swish() -> void:
	SoundManager.play_sfx(Global.SFX.BLIP, -5.0, randf_range(0.7, 0.9))


func _toggle_permanent_invincibility() -> void:
	set_permanent_invincibility(not _permanent_invincibility)


func _update_last_known_ground_position() -> void:
	if is_on_floor():
		_last_known_ground_position = global_position


func _debug_setup() -> void:
	var debug_category_name: String = "Player"
	DebugMenu.add_category("Player")
	DebugMenu.add_option(debug_category_name, "toggle invincibility", _toggle_permanent_invincibility)
#	DebugMenu.add_option(debug_category_name, "restore health", fully_heal)
#	DebugMenu.add_option(debug_category_name, "toggle collision", _toggle_collision)
	DebugMenu.add_option(debug_category_name, "gain_rusty_sword", _debug_gain_rusty_sword)


func _get_move_input() -> void:
	direction.x = Input.get_axis("move_left", "move_right")
	direction.y = Input.get_axis("move_forward", "move_backward")
	direction = direction.rotated(-_camera.rotation.y).normalized()


func _update_facing(delta: float) -> void:
	if _get_horizontal_speed() > 0.1:
		_mesh_container.rotation.y = lerp_angle(_mesh_container.rotation.y, atan2(-velocity.x, -velocity.z), delta * ANGULAR_ACCELERATION)


#func _update_animation() -> void:
#	var new_anim: int = -1
#	if _get_horizontal_speed() > 0.1:
#		new_anim = Global.HUMANOID_ANIMATIONS.RUN
#	else:
#		new_anim = Global.HUMANOID_ANIMATIONS.IDLE
#
#	if new_anim == _current_anim or new_anim == -1:
#		return
#
#	_current_anim = _character_mesh.play_anim(new_anim)


func _update_camera_rotation(delta) -> void:
	_camera.rotation.y = lerp_angle(_camera.rotation.y, _camera_positions[_camera_position].rotation.y, delta * CAMERA_ANGULAR_ACCELERATION)
	_camera.rotation.x = lerp_angle(_camera.rotation.x, _camera_positions[_camera_position].rotation.x, delta * CAMERA_ANGULAR_ACCELERATION)
	_camera.rotation.z = lerp_angle(_camera.rotation.z, _camera_positions[_camera_position].rotation.z, delta * CAMERA_ANGULAR_ACCELERATION)
	_camera.position = lerp(_camera.global_transform.origin, _camera_positions[_camera_position].global_transform.origin, delta * CAMERA_ANGULAR_ACCELERATION)


func _rotate_camera_right() -> void:
	set_camera_position(_camera_position - 1)


func _rotate_camera_left() -> void:
	set_camera_position(_camera_position + 1)


#func _set_current_weapon_data(new_weapon_data: WeaponData) -> void:
#	_current_weapon_data = new_weapon_data
#	_character_mesh.equip_weapon(new_weapon_data)


func _debug_gain_rusty_sword() -> void:
	_debug_gain_item(Global.ITEMS.RUSTY_SWORD)


func _debug_gain_item(item_id: int) -> void:
	SignalManager.emit_signal("item_gained", item_id)


func _connect_signals() -> void:
	SignalManager.paused_changed.connect(_on_game_paused_changed)
	_health_component.health_changed.connect(_on_health_changed)
	_hurtbox_component.hit_taken.connect(take_hit)
	_last_ground_position_timer.timeout.connect(_on_last_ground_position_timer_timeout)
	_mesh_component.flashing_finished.connect(_on_flashing_finished)
#	SignalManager.connect("soul_joined",Callable(self,"_on_soul_joined"))
#	SignalManager.connect("item_equipped",Callable(self,"_on_item_equipped"))


#func _on_flash_timer_timeout() -> void:
#	if _flash_amount >= HIT_FLASH_AMOUNT:
#		_stop_flash()
#		return
#
#	_flash_amount += 1
#	_mesh_container.visible = not _mesh_container.visible


func _on_game_paused_changed(new_game_paused: bool) -> void:
	set_paused(new_game_paused)


#func _on_soul_joined(soul_name: int) -> void:
#	set_show_souls(true)
#
#	_souls_joined[soul_name] = true


#func _on_item_equipped(new_item_data: ItemData) -> void:
#	match new_item_data.item_type:
#		Global.ITEM_TYPES.WEAPON:
#			_set_current_weapon_data(new_item_data)


func _on_last_ground_position_timer_timeout() -> void:
	_update_last_known_ground_position()


func _on_hit_taken() -> void:
	pass


func _on_health_changed(current_health: int, max_health: int) -> void:
	SignalManager.player_health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		die()


func _on_flashing_finished() -> void:
	_hurtbox_component.check_for_damage()
