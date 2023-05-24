class_name UpgradeScreen
extends CanvasLayer


signal upgrade_selected(upgrade: AbilityUpgrade)

@export var _upgrade_card_scene: PackedScene

@onready var _card_container: HBoxContainer = %CardContainer


func _ready():
	get_tree().paused = true


func set_ability_upgrades(new_upgrades: Array[AbilityUpgrade]) -> void:
	for upgrade in new_upgrades:
		var card_instance: AbilityUpgradeCard = _upgrade_card_scene.instantiate()
		_card_container.add_child(card_instance)
		card_instance.set_ability_upgrade(upgrade)
		card_instance.selected.connect(_on_upgrade_card_selected.bind(upgrade))


func _on_upgrade_card_selected(upgrade: AbilityUpgrade) -> void:
	upgrade_selected.emit(upgrade)
	get_tree().paused = false
	queue_free()
