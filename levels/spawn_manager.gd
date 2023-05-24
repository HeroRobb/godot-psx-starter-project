class_name SpawnManager
extends Node


@export_range(30, 100) var total_enemy_limit: int = 50
@export var spawn_scenes: Array[PackedScene]
@export var spawn_position_parent_paths: Array[NodePath]

var delay_seconds: float = 5.0 : set = set_delay_seconds
var delay_randomness: float = 0.1
var random_position_variance: Vector3 = Vector3.ZERO

var _spawns_remaining: int = 0
var _current_spawns: int = 0 : set = _set_current_spawns
var _spawn_parents: Array[Node]

@onready var _spawn_timer: Timer = $SpawnTimer

func _ready() -> void:
	_connect_signals()
	
	for path in spawn_position_parent_paths:
		var new_spawn_parent: Node = get_node_or_null(path)
		if not new_spawn_parent:
			continue
		_spawn_parents.append(new_spawn_parent)
	
	if _spawn_parents.is_empty():
		_spawn_parents.append(get_parent())


func spawn_wave(wave_size: int = 50, spawn_delay_seconds: float = 0.5, highest_spawn_index: int = -1) -> void:
	_spawns_remaining = wave_size
	delay_seconds = spawn_delay_seconds
	
	spawn()


func spawn() -> void:
	_create_random_instance()
	_current_spawns += 1
	
	_spawns_remaining -= 1
	if _spawns_remaining > 1:
		_spawn_timer.start(delay_seconds)
		return
	
	_spawns_remaining = 0
	SignalManager.spawning_finished.emit()


func set_delay_seconds(new_delay_seconds: float) -> void:
	delay_seconds = new_delay_seconds
	_spawn_timer.wait_time = delay_seconds


func _create_random_instance() -> void:
	var random_spawn_index: int = randi_range(0, spawn_scenes.size() - 1)
	var instance: Node = spawn_scenes[random_spawn_index].instantiate()
	var random_position_parent_index: int = randi_range(0, _spawn_parents.size() - 1)
	var spawn_position_parent: Node = get_node(spawn_position_parent_paths[random_position_parent_index])
	
	var spawn_position: Vector3 = _get_spawn_global_position(spawn_position_parent.global_position)
	SignalManager.enemy_spawned.emit(instance)
	instance.top_level = true
	instance.global_position = spawn_position


func _get_spawn_global_position(offset_vector: Vector3) -> Vector3:
	if random_position_variance == Vector3.ZERO:
		return offset_vector
	
	var random_spawn_position: Vector3 = offset_vector
	random_spawn_position.x += randf_range(-random_position_variance.x, random_position_variance.x)
	random_spawn_position.y += randf_range(-random_position_variance.y, random_position_variance.y)
	random_spawn_position.z += randf_range(-random_position_variance.z, random_position_variance.z)
	
	return random_spawn_position


func _set_current_spawns(new_current_spawns: int) -> void:
	_current_spawns = max(new_current_spawns, 0)
	SignalManager.spawns_remaining_changed.emit(_current_spawns)
	
	if _current_spawns == 0 and _spawns_remaining == 0:
		SignalManager.all_spawns_removed.emit()


func _connect_signals() -> void:
	_spawn_timer.timeout.connect(spawn)
	SignalManager.wave_spawn_requested.connect(spawn_wave)
	SignalManager.enemy_died.connect(_on_enemy_died)


func _on_enemy_died(enemy_name: String) -> void:
	_current_spawns -= 1
