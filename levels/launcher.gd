@tool
class_name Launcher
extends Control

## Pseudo launcher for setting options that you want to set before the game properly starts.
##
## You should extend this script and override the handle_first_selection and
## handle_second_selection functions. The launcher disables post processing
## shaders from ScreenSpaceShaderManager and GameManager until one of the
## options is selected.


@export var background_color: Color = Color.BLACK : set = set_background_color
@export var menu_title = "Game Launcher" : set = set_menu_title
@export var first_selection_name = "Begin fullscreen" : set = set_first_selection_name
@export var second_selection_name = "Begin windowed" : set = set_second_selection_name
@export var exit_selection_name = "Exit" : set = set_exit_selection_name
@export var next_level_id: Global.LEVELS = Global.LEVELS.INTRO

@onready var _selection_container: SelectionContainer = $CenterContainer/MenuSelectionContainer
@onready var _background_color_rect: ColorRect = $BackgroundColorRect
@onready var _first_selection: MenuSelection = %FirstSelection
@onready var _second_selection: MenuSelection = %SecondSelection
@onready var _exit_selection: MenuSelection = %ExitSelection

func _ready() -> void:
	SignalManager.pp_all_disabled.emit()
	_selection_container.option_confirmed.connect(_on_selection_container_selection_confirmed)
	SignalManager.set_window_mode.emit(Global.WINDOW_MODES.WINDOWED_MED)
	_selection_container.menu_available = true


func handle_first_selection() -> void:
	pass


func handle_second_selection() -> void:
	pass


func set_menu_title(new_menu_title: String) -> void:
	menu_title = new_menu_title
	
	if _selection_container:
		_selection_container.title = new_menu_title


func set_first_selection_name(new_name: String) -> void:
	first_selection_name = new_name
	
	if _first_selection:
		_first_selection.selection_name = first_selection_name


func set_second_selection_name(new_name: String) -> void:
	second_selection_name = new_name
	
	if _second_selection:
		_second_selection.selection_name = second_selection_name


func set_exit_selection_name(new_name: String) -> void:
	exit_selection_name = new_name
	
	if _exit_selection:
		_exit_selection.selection_name = exit_selection_name


func set_background_color(new_color: Color) -> void:
	background_color = new_color
	
	if _background_color_rect:
		_background_color_rect.color = background_color


func _on_selection_container_selection_confirmed(selection_name: String) -> void:
	match selection_name:
		first_selection_name:
			handle_first_selection()
		
		second_selection_name:
			handle_second_selection()
		
		exit_selection_name:
			get_tree().quit()
	
	SignalManager.change_scene_needed.emit(next_level_id, false, 0.05)
	SignalManager.pp_default_shaders_enabled_changed.emit(true)
