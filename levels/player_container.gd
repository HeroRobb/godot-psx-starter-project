class_name PlayerContainer
extends Node3D


@onready var _player
@onready var _player_spawn_position_container := $PlayerSpawnPositionContainer

var _player_spawn_positions: Dictionary


func _ready() -> void:
	SignalManager.enemy_spawned.connect(_on_enemy_spawned)
	
	_add_player_spawn_positions()


# Replace Node with whatever class you have for your player.
func get_player() -> Node:
	return _player


func move_player_to_spawn_position(level_id: int) -> void:
	if not _player:
		return
	
	var spawn_position: PlayerSpawnPosition = _player_spawn_positions.get(level_id)
	
	if not spawn_position:
		spawn_position = _player_spawn_position_container.get_child(0)
	
	_player.global_transform.origin = spawn_position.global_transform.origin


func teleport_player_to_safety() -> void:
	pass


func _add_player_spawn_positions() -> void:
	for child in _player_spawn_position_container.get_children():
		if child is PlayerSpawnPosition:
			_player_spawn_positions[child.from_level_id] = child


func _on_enemy_spawned(spawned_enemy: Node3D) -> void:
	if spawned_enemy.has_method("set_player"):
		spawned_enemy.set_player(_player)
