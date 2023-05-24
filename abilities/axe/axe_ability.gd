class_name AxeAbility
extends Node2D


const MAX_RADIUS: float = 50

@export var _rotations: float = 2
@export var _seconds_alive: float = 3

var _player: Node2D
var _base_rotation: Vector2 = Vector2.RIGHT
var _fading: bool = false

@onready var _hitbox_component: HitboxComponent2D = $HitboxComponent2D


func _ready() -> void:
	_hitbox_component.hit_limit_reached.connect(_on_hit_limit_reached)
	
	_player = get_tree().get_first_node_in_group("player")
	_base_rotation = _base_rotation.rotated(randf_range(0, TAU))
	
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(_spiral, 0.0, _rotations, _seconds_alive)
	tween.tween_callback(_begin_fade)


func set_damage_source(damage_source: DamageSource) -> void:
	_hitbox_component.damage_source = damage_source


func _spiral(rotations: float) -> void:
	if not _player:
		return
	
	var ratio_finished: float = rotations / _rotations
	var current_radius: float = ratio_finished * MAX_RADIUS
	var current_direction: Vector2 = _base_rotation.rotated(rotations * TAU)
	
	global_position = _player.global_position + current_direction * current_radius


func _begin_fade() -> void:
	if _fading: return
	
	_fading = true
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.5)


func _on_hit_limit_reached() -> void:
	_begin_fade()
