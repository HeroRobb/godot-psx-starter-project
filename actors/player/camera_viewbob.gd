extends Camera3D
# Calculates and applies camera viewbob, based checked input from the player's character controller.
# This is all visual and feel-based, so not really a good candidate for unit testing

const CAMERA_BOB_SPEED := 15
const CAMERA_BOB_DISTANCE := 0.15
const CAMERA_INTERPOLATE_SPEED := 10
const CAMERA_ROLL_TURN_DISTANCE := 0.4
const CAMERA_ROLL_STRAFE_DISTANCE := 0.05
const CAMERA_WALK_ROLL_DISTANCE := 0.015
const DEFAULT_FOV := 90.0
const FOV_OUT := 95.0
const FOV_IN := 70.0

var shake_amount = 0
var default_h_offset = h_offset
var default_v_offset = v_offset
var y_bob_amount := 0.75
var turn_roll_amount := 0.75
var strafe_roll_amount := 0.75
var _camera_bob_weight := 0.0
var zoom := 90.0 : set = set_zoom

@onready var shake_timer: Timer = $ShakeTimer
@onready var shake_tween := $ShakeTween
@onready var zoom_tween := $ZoomTween


func _ready() -> void:
	# warning-ignore-all:return_value_discarded
	SignalManager.screeenshake_requested.connect(_shake)
	shake_timer.timeout.connect(_on_shake_timer_timeout())
	set_process(false)


func _process(delta):
	h_offset = randf_range(-shake_amount, shake_amount) * delta + default_h_offset
	v_offset = randf_range(-shake_amount, shake_amount) * delta + default_v_offset


func set_zoom(new_zoom: float) -> void:
	zoom = new_zoom
	zoom_tween.interpolate_property(self, "fov", fov, zoom, 0.5)
	zoom_tween.start()

# Calculates and smoothly interpolates to a new transform.
# Call this from the player character controller's `_physics_process()`.
func update_transform(delta: float, is_walking: bool, turn_amount: float, strafe_direction: float, sprinting: bool):
	self._camera_bob_weight = self._camera_bob_weight + delta if is_walking else 0.0

	var target_transform := _get_target_transform(
		_camera_bob_weight,
		turn_amount,
		strafe_direction,
		self.y_bob_amount * 3 if sprinting else self.y_bob_amount,
		self.turn_roll_amount,
		self.strafe_roll_amount
	)

	self.transform = self.transform.interpolate_with(target_transform, delta * CAMERA_INTERPOLATE_SPEED)


# Calculates target transform based checked input parameters
static func _get_target_transform(
	bob_weight: float,
	turn_amount: float,
	strafe_direction: float,
	p_y_bob_amount: float,
	p_turn_roll_amount: float,
	p_strafe_roll_amount: float
) -> Transform3D:
	var _target_camera_offset := Transform3D.IDENTITY
	var y_bob := Transform3D.IDENTITY.translated(
		Vector3.DOWN * sin(-bob_weight * CAMERA_BOB_SPEED) * CAMERA_BOB_DISTANCE * p_y_bob_amount
	)
	var turn_roll := Transform3D.IDENTITY.rotated(
		Vector3.BACK, turn_amount * CAMERA_ROLL_TURN_DISTANCE * p_turn_roll_amount
	)
	var strafe_roll := Transform3D.IDENTITY.rotated(
		Vector3.FORWARD, strafe_direction * CAMERA_ROLL_STRAFE_DISTANCE * p_strafe_roll_amount
	)

	return y_bob * turn_roll * strafe_roll


func _shake(new_shake, shake_time=0.4, shake_limit=100):
	shake_amount += new_shake
	if shake_amount > shake_limit:
		shake_amount = shake_limit
	
	shake_timer.wait_time = shake_time
	
	shake_tween.stop_all()
	set_process(true)
	shake_timer.start()


func _on_shake_timer_timeout():
	shake_amount = 0
	set_process(false)
	
	shake_tween.interpolate_property(self, "h_offset", h_offset, default_h_offset,
	0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	shake_tween.interpolate_property(self, "v_offset", v_offset, default_v_offset,
	0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
	shake_tween.start()
