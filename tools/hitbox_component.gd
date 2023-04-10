class_name HitboxComponent
extends Area3D


signal hit_limit_reached()

enum HURTBOX_TYPES {
	FRIENDLY,
	ENEMY,
	BOTH
}

@export var can_damage: HURTBOX_TYPES = HURTBOX_TYPES.FRIENDLY
@export var hits_available: int = 1
@export var damage_source: DamageSource

var hits_given: int = 0 : set = set_hits_given
var enabled: bool = true : set = set_enabled


func _ready() -> void:
	_initialize_collision()


func set_enabled(new_enabled: bool) -> void:
	enabled = new_enabled
	
	monitorable = enabled
	monitoring = false


func set_hits_given(new_hits_given: int) -> void:
	hits_given = new_hits_given
	
	if hits_given <= 0:
		set_enabled(false)
		hit_limit_reached.emit()


func _initialize_collision() -> void:
	collision_mask = 0
	
	match can_damage:
		HURTBOX_TYPES.FRIENDLY:
			collision_layer = 16
		HURTBOX_TYPES.ENEMY:
			collision_layer = 8
		HURTBOX_TYPES.BOTH:
			collision_layer = 24
