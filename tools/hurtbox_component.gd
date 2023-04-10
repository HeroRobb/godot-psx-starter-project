class_name HurtboxComponent
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
	if not area is HitboxComponent:
		return
	
	if _health_component:
		var hitbox: HitboxComponent = area
		_health_component.take_damage(hitbox.damage_source)
	
	hit_taken.emit()
