class_name UpgradeManager
extends Node


@export var _upgrade_screen: PackedScene
@export var _experience_manager: ExperienceManager
@export var _upgrade_pool: Array[AbilityUpgrade]

var _current_upgrades: Dictionary
var _upgrades_per_level: int = 3


func _ready():
	_experience_manager.level_up_achieved.connect(_on_level_up)


func _apply_upgrade(upgrade: AbilityUpgrade) -> void:
	var has_upgrade: bool = _current_upgrades.has(upgrade.id)
	
	if has_upgrade:
		_current_upgrades[upgrade.id]["quantity"] += 1
	
	else:
		_current_upgrades[upgrade.id] = {
			"resource": upgrade,
			"quantity": 1
		}
	
	var quantity_owned: int = _current_upgrades[upgrade.id]["quantity"]
	_check_upgrade_quantity(upgrade, quantity_owned)
	
	SignalManager.ability_upgrade_added.emit(upgrade, _current_upgrades.duplicate())


func _get_random_upgrades() -> Array[AbilityUpgrade]:
	var new_upgrades: Array[AbilityUpgrade] = []
	var available_upgrades: Array[AbilityUpgrade] = _upgrade_pool.duplicate()
	
	for i in _upgrades_per_level:
		var new_upgrade: AbilityUpgrade = available_upgrades.pick_random()
		
		if available_upgrades.is_empty(): break
		
		new_upgrades.append(new_upgrade)
		available_upgrades = available_upgrades.filter(func (upgrade: AbilityUpgrade): return not upgrade.id == new_upgrade.id)
	
	return new_upgrades


func _on_level_up(new_level: int) -> void:
	var upgrade_screen_instance: UpgradeScreen = _upgrade_screen.instantiate()
	add_child(upgrade_screen_instance)
	var new_upgrades: Array[AbilityUpgrade] = _get_random_upgrades()
	upgrade_screen_instance.set_ability_upgrades(new_upgrades)
	upgrade_screen_instance.upgrade_selected.connect(_on_upgrade_selected)


func _on_upgrade_selected(upgrade: AbilityUpgrade) -> void:
	_apply_upgrade(upgrade)


func _check_upgrade_quantity(new_upgrade: AbilityUpgrade, quantity_owned: int) -> void:
	if new_upgrade.max_quantity < 0: return
	if quantity_owned < new_upgrade.max_quantity: return
	
	_upgrade_pool = _upgrade_pool.filter(func (pool_upgrade: AbilityUpgrade): return not pool_upgrade.id == new_upgrade.id)
