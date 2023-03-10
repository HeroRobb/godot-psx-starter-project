class_name NPCContainer
extends Node3D


func _ready() -> void:
	SignalManager.enemy_spawned.connect(_on_enemy_spawned)


# Replace node with enemy class
func _on_enemy_spawned(spawned_enemy: Node) -> void:
	add_child(spawned_enemy)
