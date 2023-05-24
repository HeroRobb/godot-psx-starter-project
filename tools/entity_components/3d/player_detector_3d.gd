class_name PlayerDetector3D
extends Area3D


signal player_entered()
signal player_exited()

@export var one_shot: bool = false
@export var start_enabled: bool = true

var enabled: bool : set = set_enabled


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	set_enabled(start_enabled)
	collision_mask = 1


func set_enabled(new_enabled: bool) -> void:
	enabled = new_enabled
	
	set_deferred("monitoring", enabled)


func _player_entered() -> void:
	emit_signal("player_entered")


func _player_exited() -> void:
	emit_signal("player_exited")
	if one_shot:
		set_deferred("monitoring", false)
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_entered()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_exited()
