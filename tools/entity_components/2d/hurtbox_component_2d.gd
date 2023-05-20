class_name HurtboxComponent2D
extends Area2D


signal hit_taken

enum HITBOX_SOURCES {
	FRIENDLY,
	ENEMY,
	BOTH,
}

@export var _health_component: HealthComponent
@export var can_take_hits_from: HITBOX_SOURCES = HITBOX_SOURCES.FRIENDLY
@export var _debug: bool = false

var enabled: bool = true : set = set_enabled
var _overlapping_hitbox_components: Array[HitboxComponent2D]


func _ready() -> void:
	_initialize_collision()
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func take_hit(damage_source: DamageSource) -> void:
	hit_taken.emit()
	
	if not damage_source: return
	if not _health_component: return
	
	_health_component.take_damage(damage_source)


func check_for_damage() -> void:
	if _debug: breakpoint
	
	var damage_done := false
	
	for hitbox in _overlapping_hitbox_components:
		hitbox.give_hit()
		take_hit(hitbox.damage_source)
		
		if damage_done: break


func set_enabled(new_enabled: bool) -> void:
	enabled = new_enabled
	
	monitoring = enabled
	monitorable = false


func _initialize_collision() -> void:
	collision_layer = 0
	
	match can_take_hits_from:
		HITBOX_SOURCES.FRIENDLY:
			collision_mask = 8
		HITBOX_SOURCES.ENEMY:
			collision_mask = 16
		HITBOX_SOURCES.BOTH:
			collision_mask = 24


func _on_area_entered(area: Area2D) -> void:
	if _debug: breakpoint
	
	if not area is HitboxComponent2D: return
	
	var hitbox: HitboxComponent2D = area
	
	_overlapping_hitbox_components.append(hitbox)
	hitbox.give_hit()
	take_hit(hitbox.damage_source)


func _on_area_exited(area: Area2D) -> void:
	if _debug: breakpoint
	
	if not area is HitboxComponent2D: return
	if not _overlapping_hitbox_components.has(area): return
	
	var hitbox: HitboxComponent2D = area
	_overlapping_hitbox_components.erase(hitbox)
