class_name Screenshake
extends Node

var speed: float = 30.0
var decay_rate: float = 5.0
var strength: float = 0.0

@onready var rand = RandomNumberGenerator.new()
@onready var noise = FastNoiseLite.new()


var camera: set = set_camera

# Used to keep track of where we are in the noise
# so that we can smoothly move through it
var _noise_i: float = 0.0

func _ready() -> void:
	rand.randomize()
	# Randomize the generated noise
	noise.seed = rand.randi()
	# Period affects how quickly the noise changes values
	SignalManager.screenshake_requested.connect(start_shake)
	SignalManager.screenshake_stop_requested.connect(stop_shake)


func _process(delta: float) -> void:
	if not camera:
		return
	
	# Fade out the intensity over time
	strength = lerp(strength, 0.0, decay_rate * delta)
	
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
	# so that our x and y vectors will be reading from unrelated areas of noise
	return Vector2(
		noise.get_noise_2d(1, _noise_i) * strength,
		noise.get_noise_2d(100, _noise_i) * strength
	)


func start_shake(new_speed: float, new_strength: float, new_decay_rate: float) -> void:
	if speed == new_speed and strength == new_strength and decay_rate == new_decay_rate:
		return
	
	speed = new_speed
	strength = new_strength
	decay_rate = new_decay_rate


func stop_shake() -> void:
	strength = 0


func set_camera(new_camera: Node) -> void:
	if not new_camera is Camera2D and not new_camera is Camera3D:
		return
	
	camera = new_camera
