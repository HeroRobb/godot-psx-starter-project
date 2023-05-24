class_name HitboxComponent
extends Area3D


signal hit_limit_reached()

enum HURTBOX_TYPES {
	FRIENDLY,
	ENEMY,
	BOTH
}

@export var can_damage: HURTBOX_TYPES = HURTBOX_TYPES.FRIENDLY
@export var max_hits: int = 1
@export var damage_source: DamageSource

var hits_given: int = 0 : set = set_hits_given
var enabled: bool = true : set = set_enabled

var _infinite_hits: bool = false


func _ready() -> void:
	if max_hits == -1:
		_infinite_hits = true
	
	_initialize_collision()


func give_hit() -> void:
	if not _infinite_hits:
		set_hits_given(hits_given + 1)


func set_enabled(new_enabled: bool) -> void:
	enabled = new_enabled
	
	monitorable = enabled
	monitoring = false
	
	if not enabled:
		collision_layer = 0


func set_hits_given(new_hits_given: int) -> void:
	hits_given = new_hits_given
	
	if hits_given >= max_hits:
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
