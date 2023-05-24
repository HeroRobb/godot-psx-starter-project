class_name Screenshake
extends Node

var speed: float = 30
var decay_rate: float = 5
var strength: float = 0
var camera: set = set_camera

var _base_speed: float = 0
var _base_strength: float = 0
var _noise_i: float = 0.0

@onready var _rand = RandomNumberGenerator.new()
@onready var _noise = FastNoiseLite.new()

func _ready() -> void:
	_rand.randomize()
	# Randomize the generated _noise
	_noise.seed = _rand.randi()
	# Period affects how quickly the _noise changes values
	SignalManager.screenshake_requested.connect(start_shake)
	SignalManager.screenshake_stop_requested.connect(stop_shake)


func _process(delta: float) -> void:
	if not camera:
		return
	
	if strength <= 0.1:
		strength = _base_strength
		speed = _base_speed
		decay_rate = 0
	
	# Fade out the intensity over time
	strength = lerpf(strength, 0, decay_rate * delta)
	
	# Shake by adjusting camera.offset so we can move the camera around the level via it's position
	var noise_offset: Vector2 = get_noise_offset(delta)
	
	if camera is Camera2D:
		var camera_2d: Camera2D = camera
		camera.offset = noise_offset
	
	elif camera is Camera3D:
		var camera_3d: Camera3D = camera
		camera.h_offset = noise_offset.x
		camera.v_offset = noise_offset.y


func get_noise_offset(delta: float) -> Vector2:
	_noise_i += delta * speed
	# Set the x values of each call to 'get_noise_2d' to a different value
	# so that our x and y vectors will be reading from unrelated areas of _noise
	return Vector2(
		_noise.get_noise_2d(1, _noise_i) * strength,
		_noise.get_noise_2d(100, _noise_i) * strength
	)


func start_shake(new_speed: float, new_strength: float, new_decay_rate: float) -> void:
	if speed == new_speed and strength == new_strength and decay_rate == new_decay_rate:
		return
	
	speed = new_speed
	strength = new_strength
	decay_rate = new_decay_rate
	
	if decay_rate == 0.0:
		_base_speed = speed
		_base_strength = strength
	
	set_process(true)


func stop_shake() -> void:
	strength = 0


func set_camera(new_camera: Node) -> void:
	if not new_camera is Camera2D and not new_camera is Camera3D:
		return
	
	camera = new_camera
