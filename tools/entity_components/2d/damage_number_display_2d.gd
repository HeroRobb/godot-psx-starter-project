class_name DamageNumberDisplay2D
extends Control


var damage_amount: int = 1 : set = set_damage_amount

@onready var _label: Label = %NumberLabel


func set_damage_amount(new_amount: int) -> void:
	damage_amount = new_amount
	_label.text = str(damage_amount)
