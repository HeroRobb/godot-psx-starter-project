class_name Launcher
extends Control

## Pseudo launcher for options that you want to set before the game properly starts. It disables
## post processing shaders and 
@export var color: Color = Color.BLACK
@export var menu_title = "Game Launcher" : set = set_menu_title
@export var first_option_title = "Begin fullscreen"
@export var second_option_title = "Begin windowed"
@export var exit_option_title = "Exit"

@export var next_level_id: Global.LEVELS = Global.LEVELS.INTRO

@onready var _selection_container: SelectionContainer = $CenterContainer/MenuSelectionContainer


func _ready() -> void:
	SignalManager.pp_all_disabled.emit()
	_selection_container.option_confirmed.connect(_on_option_container_option_confirmed)
#	await get_tree().process_frame
	SignalManager.set_window_mode.emit(Global.WINDOW_MODES.WINDOWED_MED)
	_selection_container.menu_available = true


func handle_first_option() -> void:
	pass


func handle_second_option() -> void:
	pass


func set_menu_title(new_menu_title: String) -> void:
	menu_title = new_menu_title
	_selection_container.title = new_menu_title


func _on_option_container_option_confirmed(option_name: String) -> void:
	match option_name:
		first_option_title:
			handle_first_option()
		
		second_option_title:
			handle_second_option()
		
		exit_option_title:
			get_tree().quit()
	
	SignalManager.change_scene_needed.emit(next_level_id, false, 0.05)
	SignalManager.pp_default_shaders_enabled_changed.emit(true)
