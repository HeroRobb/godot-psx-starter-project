class_name DamageSource
extends Resource


@export_range(0, 1000) var damage: int = 1
@export var damage_types: Array[Global.DAMAGE_TYPES]


func add_damage_types(new_damage_types: Array[Global.DAMAGE_TYPES]) -> void:
	for type in new_damage_types:
		if not damage_types.has(type):
			damage_types.append(type)


func remove_damage_types(removed_damage_types: Array[Global.DAMAGE_TYPES]) -> void:
	for type in removed_damage_types:
		if damage_types.has(type):
			damage_types.erase(type)
