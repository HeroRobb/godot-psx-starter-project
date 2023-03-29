extends Control


enum MENUS {
	BASE,
	LOAD,
	OPTION,
}

const BASE_START_SELECTION = "Start"
const BASE_LOAD_SELECTION = "Load game"
const BASE_OPTIONS_SELECTION = "Options"
const BASE_QUIT_SELECTION = "Exit"
const LOAD_SLOT_1_SELECTION = "1"
const LOAD_SLOT_2_SELECTION = "2"
const LOAD_SLOT_3_SELECTION = "3"
const LOAD_BACK_SELECTION = "Back"

@export var starting_level_id: Global.LEVELS = Global.LEVELS.TEST

var _current_menu_id: int = MENUS.BASE
var _finished_selection: bool = false

@onready var _menu_timer: Timer = $MenuTimer
@onready var _selection_containers: Dictionary = {
	MENUS.BASE: $Menus/MarginContainer/BaseMenuSelectionContainer,
	MENUS.LOAD: $Menus/MarginContainer/LoadMenuSelectionContainer
}


func _ready() -> void:
	_menu_timer.wait_time = SelectionContainer.TRANS_DURATION + 0.2
	_connect_signals()
	_show_menu()


func _switch_menu(new_menu_id: int) -> void:
	_finished_selection = false
	if _current_menu_id == new_menu_id:
		return
	
	var current_selection_container: SelectionContainer = _selection_containers[_current_menu_id]
	var new_selection_container: SelectionContainer = _selection_containers[new_menu_id]
	current_selection_container.menu_available = false
	await current_selection_container.transition_finished
	
	_current_menu_id = new_menu_id
	new_selection_container.menu_available = true


func _show_menu() -> void:
	_switch_menu(MENUS.BASE)


func _on_base_option_confirmed(selection_name: String) -> void:
	match selection_name:
		BASE_START_SELECTION:
			SignalManager.change_scene_requested.emit(starting_level_id)
		BASE_LOAD_SELECTION:
			_switch_menu(MENUS.LOAD)
		BASE_QUIT_SELECTION:
			get_tree().quit()
		_:
			return
	
	_finished_selection = true


func _on_load_selection_confirmed(selection_name: String) -> void:
	match selection_name:
		LOAD_SLOT_1_SELECTION: SignalManager.game_save_load_requested.emit(1)
		LOAD_SLOT_2_SELECTION: SignalManager.game_save_load_requested.emit(2)
		LOAD_SLOT_3_SELECTION: SignalManager.game_save_load_requested.emit(3)
		LOAD_BACK_SELECTION: _switch_menu(MENUS.BASE)
		_: return
	
	_finished_selection = true


func _connect_signals() -> void:
	var base_selection_container: SelectionContainer = _selection_containers[MENUS.BASE]
	base_selection_container.selection_confirmed.connect(_on_base_option_confirmed)
	var load_selection_container: SelectionContainer = _selection_containers[MENUS.LOAD]
	load_selection_container.selection_confirmed.connect(_on_load_selection_confirmed)
