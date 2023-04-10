class_name HealthComponent
extends Node


signal health_changed(health: int, max_health: int)
signal health_reached_zero()

@export var max_health: int = 3 : set = set_max_health

var current_health: int : set = set_current_health
var invincible: bool = false
var _previous_health: int


func _ready() -> void:
	_initialize_health()


func heal(heal_amount: int) -> void:
	set_current_health(current_health + heal_amount)


func take_damage(damage_source: DamageSource) -> void:
	if invincible:
		return
	set_current_health(current_health - damage_source.damage)


func set_current_health(new_current_health: int) -> void:
	current_health = _previous_health
	current_health = clamp(new_current_health, 0, max_health)
	
	health_changed.emit(current_health, max_health)
	
	if current_health <= 0:
		health_reached_zero.emit()


func set_max_health(new_max_health: int) -> void:
	max_health = new_max_health
	
	if current_health > max_health:
		current_health = max_health


func _initialize_health() -> void:
	current_health = max_health
