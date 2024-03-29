class_name HurtboxComponent3D
extends Area3D


signal hit_taken

enum HITBOX_SOURCES {
	FRIENDLY,
	ENEMY,
	BOTH,
}

@export var health_component_path: NodePath
@export var can_take_hits_from: HITBOX_SOURCES = HITBOX_SOURCES.FRIENDLY

var enabled: bool = true : set = set_enabled

var _health_component: HealthComponent


func _ready() -> void:
	if health_component_path:
		_health_component = get_node(health_component_path)
	
	_initialize_collision()
	area_entered.connect(_on_area_entered)


func take_hit(damage_source: DamageSource) -> void:
	_health_component.take_damage(damage_source)
	hit_taken.emit()


func check_for_damage() -> void:
	var possible_damage_areas = get_overlapping_areas()
	var damage_done := false
	
	for area in possible_damage_areas:
		if not area is HitboxComponent3D:
			continue
		var hitbox: HitboxComponent3D = area
		hitbox.give_hit()
		take_hit(hitbox.damage_source)
		
		if damage_done:
			break


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


func _on_area_entered(area: Area3D) -> void:
	if not area is HitboxComponent3D:
		return
	
	var hitbox: HitboxComponent3D = area
	hitbox.give_hit()
	take_hit(hitbox.damage_source)
