class_name AbilityUpgradeCard
extends PanelContainer


signal selected

@onready var _name_label: Label = %NameLabel
@onready var _description_label: Label = %DescriptionLabel


func _ready():
	gui_input.connect(_on_gui_input)


func set_ability_upgrade(new_ability_upgrade: AbilityUpgrade) -> void:
	_name_label.text = new_ability_upgrade.name
	_description_label.text = new_ability_upgrade.description


func _on_gui_input(event: InputEvent) -> void:
	if not event.is_action("left_click"):
		return
	
	selected.emit()
