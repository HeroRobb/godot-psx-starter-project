class_name HealthBar
extends Control


@onready var empty_health_texture: TextureRect = $EmptyHealth
@onready var full_health_texture: TextureRect = $FullHealth


func _ready() -> void:
	scale = Vector2(0.75, 0.75)


func set_health_bar(health: int, max_health: int) -> void:
	empty_health_texture.size.x = max_health * 5
	full_health_texture.size.x = health * 5


func ensure_scale() -> void:
	await(get_tree().process_frame)
	scale = Vector2(0.75, 0.75)
