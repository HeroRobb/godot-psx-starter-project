class_name PlayerContainer
extends Node3D


var fall_damage: int = 1

@onready var _player #: PlayerTopDown = $PlayerTopDown
#@onready var _player_camera: Camera3D = $Camera3D
@onready var _player_spawn_position_container := $PlayerSpawnPositionContainer

var _player_spawn_positions: Dictionary


func _ready() -> void:
	SignalManager.enemy_spawned.connect(_on_enemy_spawned)
	
	_add_player_spawn_positions()


# Replace Node with whatever class you have for your player.
func get_player() -> Node:
	return _player


#func get_player_camera() -> Camera3D:
#	return _player_camera


func set_fall_damage(new_fall_damage: int) -> void:
	fall_damage = new_fall_damage


func move_player_to_spawn_position(level_id: int) -> void:
	if not _player:
		return
	
	var spawn_position: PlayerSpawnPosition = _player_spawn_positions.get(level_id)
	
	if not spawn_position:
		spawn_position = _player_spawn_position_container.get_child(0)
	
	_player.global_transform.origin = spawn_position.global_transform.origin
#	_player.set_mesh_rotation(spawn_position.rotation)
#	_player.set_camera_position(spawn_position.spawn_camera_position)


func teleport_player_to_safety() -> void:
	_player.return_to_last_known_ground_position(fall_damage)


func _add_player_spawn_positions() -> void:
	for child in _player_spawn_position_container.get_children():
		if child is PlayerSpawnPosition:
			_player_spawn_positions[child.from_level_id] = child


func _on_enemy_spawned(spawned_enemy: Node3D) -> void:
	if spawned_enemy.has_method("set_player"):
		spawned_enemy.set_player(_player)
