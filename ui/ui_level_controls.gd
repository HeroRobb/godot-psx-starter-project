class_name UILevelControls
extends Control


signal next_camera_requested()
signal auto_camera_toggle_requested()
signal favorite_scene_requested()
signal next_scene_requested()
signal last_scene_requested()

enum UI {
	CONTROLS,
	SAVE,
	LOAD
}

const HIDE_CONTROLS_KEY = "hide level ui"

@export var starting_ui: UI = UI.CONTROLS
@export var start_active: bool = true

var active: bool = false
var hide_controls: bool = false : set = set_hide_controls

var _current_ui: UI = UI.CONTROLS

@onready var _ui_label: Label = %UILabel
@onready var _controls_container: VBoxContainer = %ControlsLabelContainer
@onready var _ui_save: CenterContainer = %UISave


func _ready() -> void:
	active = start_active
	switch_ui(starting_ui)
	var saved_hide_ui = ResourceManager.get_global_data(HIDE_CONTROLS_KEY)
	if saved_hide_ui == null:
		ResourceManager.add_global_data(HIDE_CONTROLS_KEY, hide_controls)
		saved_hide_ui = hide_controls
	
	hide_controls = saved_hide_ui


func switch_ui(new_ui: UI) -> void:
	_current_ui = new_ui
	
	match _current_ui:
		UI.CONTROLS:
			_ui_label.text = "Controls"
			_ui_save.hide()
			if hide_controls:
				return
			_controls_container.show()
		UI.SAVE:
			_ui_label.text = "Save"
			_controls_container.hide()
			_ui_save.show()
		UI.LOAD:
			_ui_label.text = "Load"
			_controls_container.hide()
			_ui_save.show()


func handle_input(event: InputEvent) -> void:
	if not active:
		return
	
	match _current_ui:
		UI.CONTROLS: _handle_controls_input(event)
		UI.SAVE: _handle_save_input(event)
		UI.LOAD: _handle_load_input(event)


func set_hide_controls(new_hide_controls: bool) -> void:
	hide_controls = new_hide_controls
	_controls_container.visible = not hide_controls
	
	ResourceManager.add_global_data(HIDE_CONTROLS_KEY, hide_controls)


func _handle_controls_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		next_camera_requested.emit()
	if event.is_action_pressed("auto_cycle_cameras"):
		auto_camera_toggle_requested.emit()
	elif event.is_action_pressed("change_scenes"):
		active = false
		next_scene_requested.emit()
	elif event.is_action_pressed("favorite_scene"):
		favorite_scene_requested.emit()
	elif event.is_action_pressed("save_game"):
		switch_ui(UI.SAVE)
	elif event.is_action_pressed("load_game"):
		switch_ui(UI.LOAD)
	elif event.is_action_pressed("ui_cancel"):
		active = false
		get_tree().quit()
	elif event.is_action_pressed("hide_level_ui"):
		set_hide_controls(not hide_controls)


func _handle_save_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_slot_1"):
		ResourceManager.save_game(1)
	elif event.is_action_pressed("save_slot_2"):
		ResourceManager.save_game(2)
	elif event.is_action_pressed("save_slot_3"):
		ResourceManager.save_game(3)
	elif event.is_action_pressed("ui_cancel"):
		switch_ui(UI.CONTROLS)


func _handle_load_input(event: InputEvent) -> void:
	if event.is_action_pressed("save_slot_1"):
		ResourceManager.load_game(1)
	elif event.is_action_pressed("save_slot_2"):
		ResourceManager.load_game(2)
	elif event.is_action_pressed("save_slot_3"):
		ResourceManager.load_game(3)
	if event.is_action_pressed("ui_cancel"):
		switch_ui(UI.CONTROLS)
