extends Node


@export var _arena_time_manager: ArenaTimeManager
@export var _basic_enemy_scene: PackedScene
@export var _spawn_radius: float = 320
@export var _spawn_radius_buffer: int = 10
@export_range(0.4, 5.0, 0.2) var _starting_spawn_cooldown_seconds: float = 1.0
@export_range(50, 100) var _max_enemy_amount: int = 50

var _spawn_cooldown_seconds: float : set = _set_spawn_cooldown_seconds

@onready var _spawn_timer: Timer = $SpawnTimer
@onready var _player: Node2D = get_tree().get_first_node_in_group("player")


func _ready():
	_spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	_arena_time_manager.arena_difficulty_changed.connect(_on_arena_diffculty_changed)
	_spawn_cooldown_seconds = _starting_spawn_cooldown_seconds


func spawn_basic_enemy() -> void:
	var enemy_amount: int = get_tree().get_nodes_in_group("enemies").size()
	if enemy_amount >= _max_enemy_amount: return
	
	var entity_container: Node = get_tree().get_first_node_in_group("entity_container")
	var spawn_position: Vector2 = _get_spawn_position(entity_container)
	if spawn_position == Vector2.ZERO:
		return
	
	var enemy_instance: Node2D = _basic_enemy_scene.instantiate()
	if entity_container:
		entity_container.add_child(enemy_instance)
	else:
		get_parent().add_child(enemy_instance)
	
	enemy_instance.global_position = spawn_position


func _get_spawn_position(enemy_container: Node2D) -> Vector2:
	var spawn_position: Vector2 = Vector2.ZERO
	var random_direction: Vector2 = _get_random_direction()
	
	for i in 4:
		spawn_position = _player.global_position + random_direction * _spawn_radius
		var query_parameters: PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(_player.global_position, spawn_position, 1)
		var raycast_result: Dictionary = enemy_container.get_world_2d().direct_space_state.intersect_ray(query_parameters)
		
		if raycast_result.is_empty(): break
		
		random_direction = random_direction.rotated(PI / 2)
	
	return spawn_position


func _get_random_direction() -> Vector2:
	var random_direction: Vector2
	random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	return random_direction


func _update_spawn_radius() -> void:
	var viewport_size: Vector2i = get_viewport().size
	var largest_viewport_length = max(viewport_size.x, viewport_size.y)
	
	_spawn_radius = (largest_viewport_length / 2.0) + _spawn_radius_buffer


func _set_spawn_cooldown_seconds(new_cooldown_seconds: float) -> void:
	_spawn_cooldown_seconds = max(new_cooldown_seconds, 0.25)
	_spawn_timer.wait_time = _spawn_cooldown_seconds


func _on_spawn_timer_timeout() -> void:
	_spawn_timer.start()
	
	if not _player:
		return
	
	spawn_basic_enemy()


func _on_arena_diffculty_changed(new_difficulty: int) -> void:
	var time_off: float = 0.1 / 12 * new_difficulty
	_spawn_cooldown_seconds = _starting_spawn_cooldown_seconds - time_off
