extends Node3D


const LIFETIME_SECONDS: float = 4.0

var _x_rotation_speed: float = 1.0
var _y_rotation_speed: float = 1.0
var _z_rotation_speed: float = 1.0

@onready var particles: GPUParticles3D = $OrbitParticles
@onready var core: MeshInstance3D = $Core


func _ready() -> void:
	_randomize_rotation()
	_randomize_rotation_speed()
	particles.emitting = true
	create_tween().tween_property(core, "instance_shader_parameters/mixer", Color(1, 1, 1, 0), LIFETIME_SECONDS)
	SignalManager.call_delayed.emit(queue_free, LIFETIME_SECONDS)


func _physics_process(delta: float) -> void:
	core.rotation_degrees.x += _x_rotation_speed
	core.rotation_degrees.y += _y_rotation_speed
	core.rotation_degrees.z += _z_rotation_speed


func _randomize_rotation() -> void:
	rotation_degrees.x = randf_range(0, 360)
	rotation_degrees.y = randf_range(0, 360)
	rotation_degrees.z = randf_range(0, 360)


func _randomize_rotation_speed() -> void:
	_x_rotation_speed = randf_range(0.5, 3.0)
	_y_rotation_speed = randf_range(0.5, 3.0)
	_z_rotation_speed = randf_range(0.5, 3.0)
