extends Node2D


@export var _damage_number_display_scene: PackedScene
@export var _health_component: HealthComponent


func _ready() -> void:
	if not _health_component or not _damage_number_display_scene: return
	
	_health_component.damage_taken.connect(_on_damage_taken)


func _on_damage_taken(damage_amount: int) -> void:
	var foreground_container: Node2D = get_tree().get_first_node_in_group("foreground_container")
	if not foreground_container: return
	
	var damage_number_instance: DamageNumberDisplay2D = _damage_number_display_scene.instantiate()
	foreground_container.add_child(damage_number_instance)
	damage_number_instance.global_position = global_position
	damage_number_instance.damage_amount = damage_amount
