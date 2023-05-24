class_name HealthComponent
extends Node


signal health_changed(health: int, max_health: int)
signal damage_taken(damage_amount: int)
signal heal_received(heal_amount: int)
signal health_reached_zero()

@export var max_health: int = 3 : set = set_max_health

var current_health: int : set = set_current_health
var invincible: bool = false

var _previous_health: int


func _ready() -> void:
	_initialize_health()


func heal(heal_amount: int) -> void:
	heal_received.emit(heal_amount)
	
	set_current_health(current_health + heal_amount)


func take_damage(damage_source: DamageSource) -> void:
	if invincible:
		return
	
	var damage_amount: int = damage_source.damage
	
	damage_taken.emit(damage_amount)
	set_current_health(current_health - damage_amount)


## returns a float between 0 and 1 representing the ratio of current_health to max_health
func get_health_ratio() -> float:
	if current_health <= 0:
		return 0
	
	var health_ratio: float = minf( ( float(current_health) / max_health), 1)
	return health_ratio


func set_current_health(new_current_health: int) -> void:
	current_health = _previous_health
	current_health = clamp(new_current_health, 0, max_health)
	
	health_changed.emit(current_health, max_health)
	
	_check_death.call_deferred()


func set_max_health(new_max_health: int) -> void:
	max_health = new_max_health
	
	if current_health > max_health:
		current_health = max_health


func update_health() -> void:
	set_current_health(current_health)


func _check_death() -> void:
	if current_health <= 0:
		health_reached_zero.emit()


func _initialize_health() -> void:
	current_health = max_health
