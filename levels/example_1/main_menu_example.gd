extends Control


enum MENUS {
	BASE,
}

const BASE_START_SELECTION = "Start"
const BASE_QUIT_SELECTION = "Exit"

@export var starting_level_id: Global.LEVELS = Global.LEVELS.TEST

var _current_menu_id: int = MENUS.BASE

@onready var _menu_timer: Timer = $MenuTimer
@onready var _selection_containers: Dictionary = {
	MENUS.BASE: $Menus/MarginContainer/BaseMenuSelectionContainer,
}


func _ready() -> void:
	_menu_timer.wait_time = SelectionContainer.TRANS_DURATION
	_connect_signals()
	_show_menu()


func _connect_signals() -> void:
	var base_selection_container: SelectionContainer = _selection_containers[MENUS.BASE]
	base_selection_container.option_confirmed.connect(_on_base_option_confirmed)


func _switch_menu(new_menu_id: int) -> void:
	if _current_menu_id == new_menu_id:
		return
	
	for menu_type in MENUS:
		_selection_containers[MENUS[menu_type]].menu_available = false
	_menu_timer.start()
	await _menu_timer.timeout
	
	_current_menu_id = new_menu_id
	_selection_containers[_current_menu_id].menu_available = true


func _show_menu() -> void:
	_switch_menu(MENUS.BASE)


func _on_base_option_confirmed(selection_name: String) -> void:
	match selection_name:
		BASE_START_SELECTION:
			SignalManager.change_scene_needed.emit(starting_level_id)
		BASE_QUIT_SELECTION:
			get_tree().quit()
