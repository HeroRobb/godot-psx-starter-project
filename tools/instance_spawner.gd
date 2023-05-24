class_name InstanceSpawner
extends Node3D


signal instance_spawned()
signal done_spawning()

## You can drag and drop the .tscn file of the scene you want this node to
## spawn.
@export var spawn_scene: PackedScene
## A .tscn file placed here will be instanced with the spawned scene.
@export var spawn_effect: PackedScene
## This will be the scene that the spawned scenes will be children of,
## if no parent is chose, they will be children of this node's parent.
@export var spawn_parent_path: NodePath
## If this value is set above -1, this node will spawn that many instances
## before emitting the [signal done_spawning] signal.
@export var amount_of_spawns: int = -1
## If this value is set to true, this node will begin spawning instances
## immediately upon ready.
@export var auto_start: bool = false
## This value represents the amount of seconds between spawns.
@export_range(0.5, 20.0, 0.5) var delay_seconds: float = 5.0
## 0 is no randomness, 1 means the cooldown can range from 0 seconds to double the value in
## cooldown_seconds
@export_range(0.0, 1.0, 0.05) var delay_randomness: float = 0.1
## This value represents the furthest distance from this node's position that
## instances will spawn. Negative numbers are treated the same as positive
## numbers.
@export var random_position_variance: Vector3 = Vector3.ZERO

var _constant_spawning: bool = false
var _spawn_parent: Node

@onready var _spawn_timer: Timer = $SpawnTimer


func _ready() -> void:
	_connect_signals()
	
	if amount_of_spawns == 0:
		return
	
	if amount_of_spawns < 0:
		_constant_spawning = true
	
	_spawn_parent = get_node_or_null(spawn_parent_path)
	if not is_instance_valid(_spawn_parent):
		_spawn_parent = get_parent()
	
	if auto_start:
		_spawn_timer.start(delay_seconds)


func spawn() -> void:
	_create_instance(spawn_scene)
	if spawn_effect:
		_create_instance(spawn_effect)
	
	if _constant_spawning:
		_spawn_timer.start(delay_seconds)
		return
	
	amount_of_spawns -= 1
	if amount_of_spawns > 1:
		_spawn_timer.start(delay_seconds)
		return
	
	amount_of_spawns = 0
	done_spawning.emit()


func _create_instance(packed_scene: PackedScene) -> void:
	var instance: Node = packed_scene.instantiate()
	var spawn_position: Vector3 = _get_spawn_global_position()
	_spawn_parent.add_child(instance)
	instance.global_position = spawn_position


func _get_spawn_global_position() -> Vector3:
	if random_position_variance == Vector3.ZERO:
		return global_position
	
	var random_spawn_position: Vector3
	random_spawn_position.x = randf_range(-random_position_variance.x, random_position_variance.x)
	random_spawn_position.y = randf_range(-random_position_variance.y, random_position_variance.y)
	random_spawn_position.z = randf_range(-random_position_variance.z, random_position_variance.z)
	
	return random_spawn_position


func _connect_signals() -> void:
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)


func _on_spawn_timer_timeout() -> void:
	spawn()
