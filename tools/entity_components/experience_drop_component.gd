extends Node


@export var _xp_pickup: PackedScene
@export var _health_component: HealthComponent
@export_range(0, 1) var _drop_chance_on_death: float = 0.5


func _ready():
	_health_component.health_reached_zero.connect(_on_health_reached_zero)


func drop_experience() -> void:
	if not owner:
		return
	
	var xp_instance = _xp_pickup.instantiate()
	var spawn_position = owner.global_position
	var entity_container: Node = get_tree().get_first_node_in_group("entity_container")
	
	if entity_container:
		entity_container.add_child(xp_instance)
	else:
		get_parent().add_child(xp_instance)
	
	xp_instance.global_position = spawn_position


func _on_health_reached_zero() -> void:
	if not _xp_pickup:
		return
	
	if randf() > _drop_chance_on_death:
		return
	
	drop_experience()
