extends CanvasLayer

## A debug menu included with HR PSX that is able to add debug functionality to
## any node in the scene tree
##
## This is intended to be used as an autoload singleton in conjunction with the
## other autoload singletons in res://management from HR PSX. In each node that
## you want to have debug options, first create functions for those options in
## that node, then use the function [method add_category] to add a debug category, then
## use [method add_option] to add debug options that will call those functions.
## The debug options are essentially function calls, so they can do pretty much
## anything you want, change scenes, sound tests, invincibility, give items,
## whatever. F4 is the default key to open the debug menu, and this node will
## create the necessary input actions for its usage so you don't have to create
## them in every project that you use this node. It will only work if the game
## is run in the editor or if you set "debug" to true in ResourceManager by
## calling [code]ResourceManager.add_global_data("debug", true)[/code].


const _MENU_BOOKEND = "========================================"
const _SUB_MENU_BOOKEND = "--------------------------------------------------------"
const _INPUT_COOLDOWN_SECONDS = 0.05
const _TOGGLE_DEBUG_MENU_ACTION = "toggle_debug_menu"
const _DEBUG_OPTION_ACTION = "debug_option"
const _DEBUG_OPEN_FOLDER_ACTION = "debug_open_folder"

## This is the amount of lines that can comfortably fit in one page of the
## debug menu. Six is the default value for how much can comfortably fit in
## using the default font and font size from HR PSX. You may want to change
## this depending on the font, font size, and resolution you use for your game.
const DEBUG_LIMIT = 6

## This value is true if the debug menu is open and shown to the player, it is
## false if it is hidden.
var is_open := false

var _active_category_index: int = 0
var _input_on_cooldown := false
var _options: DebugOptionsList = DebugOptionsList.new()

@onready var _debug_menu := $Debug
@onready var _vbox_container := $Debug/ColorRect/VBoxContainer
@onready var _options_container := $Debug/ColorRect/VBoxContainer/OptionsContainer


func _ready() -> void:
	_add_input_actions()
	_close()


## This adds a category in the DebugMenu which will hold several debug options.
## This is necessary for adding debug options as they need a debug category to
## contain them.
func add_category(category_name: String, parent_category_index_or_name = null) -> void:
	_options.add_category(category_name, parent_category_index_or_name)
	var index: int = _options.get_index(category_name)
	var parent_index: int
	if parent_category_index_or_name:
		if parent_category_index_or_name is String:
			parent_index = _options.get_index(parent_category_index_or_name)
		parent_index = parent_category_index_or_name
	else:
		parent_index = 0
	
	_options.add_option(category_name, "Return to parent menu", _display_submenu, [parent_index])
	_options.add_option(parent_index, category_name, _display_submenu, [index])


## This adds a debug option in a debug category. Essentially, this will call
## the callable named function with the parameters in debug_parameters. You can
## use this to change scenes, give items, or anything you can do with a function.
func add_option(category_index_or_name, option_name: String, function: Callable, debug_parameters: Array = []) -> void:
	_options.add_option(category_index_or_name, option_name, function, debug_parameters)


## This clears the category of all debug options. It is good practice to do
## this *just in case* lol.
func clear_options(category_index_or_name) -> void:
	_options._get_category(category_index_or_name).clear_options()


## This disables the debug menu so that even if
## ResourceManager.get_global_data("debug") is true this Node will not respond.
## Use carefully haha.
func disable() -> void:
	set_process_input(false)


## This enables the debug menu, but will not make it available if
## ResourceManager.get_global_data("debug") is false or null.
func enable() -> void:
	set_process_input(true)


func _input(event: InputEvent) -> void:
	if not ResourceManager.get_global_data("debug") or not event is InputEventKey:
		return
	if event.is_action_pressed(_TOGGLE_DEBUG_MENU_ACTION):
		_toggle_open()
	elif event.is_action_pressed(_DEBUG_OPEN_FOLDER_ACTION):
		var global_path = ProjectSettings.globalize_path("res://")
		OS.shell_open(global_path)
	elif is_open and not _input_on_cooldown:
		_handle_options(event)
		_start_input_cooldown()



func _handle_options(event: InputEvent):
	var _input_code: int = -1
	for i in range(16):
		if event.is_action_pressed( _DEBUG_OPTION_ACTION + str(i) ):
			_input_code = i
			break
	
	if _input_code == -1:
		return
	
	_options.call_debug_function(_active_category_index, _input_code)


func _display_main_menu() -> void:
	_active_category_index = 0
	_clear_display()
	_display(_MENU_BOOKEND, 0)
	_display_options()
	_display(_MENU_BOOKEND, 2)


func _display_submenu(_index: int) -> void:
	_active_category_index = _index
	_clear_display()
	_display(_SUB_MENU_BOOKEND, 0)
	_display_options()
	_display(_SUB_MENU_BOOKEND, 2)


func _display_options() -> void:
	var option_names_array: Array = _options.get_category_option_names(_active_category_index)
	for option_index in option_names_array.size():
		var hexcized_index = _hexcize_index(option_index)
		_display("%s. %s" % [ hexcized_index, option_names_array[option_index] ])


func _hexcize_index(index) -> String:
	var hexcized_index = str(index)
	match index:
		10:
			hexcized_index = "A"
		11:
			hexcized_index = "B"
		12:
			hexcized_index = "C"
		13:
			hexcized_index = "D"
		14:
			hexcized_index = "E"
		15:
			hexcized_index = "F"
	return hexcized_index

func _toggle_open() -> void:
	if is_open:
		_close()
	else:
		_open()


func _open() -> void:
	is_open = true
	_debug_menu.show()
	_display_main_menu()


func _close() -> void:
	is_open = false
	_debug_menu.hide()
	_active_category_index = -1


func _display(text_to_display: String, child_number: int = 1) -> void:
	var text_label = Label.new()
	text_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	text_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_label.clip_text = true
	text_label.text = text_to_display
	if child_number == 1:
		_options_container.add_child(text_label)
		_vbox_container.move_child(_options_container, 1)
	else:
		_vbox_container.add_child(text_label)
		_vbox_container.move_child(text_label, child_number)


func _clear_display() -> void:
	for text_label in _options_container.get_children():
		text_label.queue_free()
	for child in _vbox_container.get_children():
		if child is Label:
			child.queue_free()


func _start_input_cooldown() -> void:
	_input_on_cooldown = true
	SignalManager.set_delayed.emit(self, "_input_on_cooldown", false, _INPUT_COOLDOWN_SECONDS)


func _add_input_actions() -> void:
	if InputMap.has_action(_TOGGLE_DEBUG_MENU_ACTION):
		return
	var input_event := InputEventKey.new()
	input_event.keycode = KEY_F4
	InputMap.add_action(_TOGGLE_DEBUG_MENU_ACTION)
	InputMap.action_add_event(_TOGGLE_DEBUG_MENU_ACTION, input_event)
	
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_F3
	InputMap.add_action(_DEBUG_OPEN_FOLDER_ACTION)
	InputMap.action_add_event(_DEBUG_OPEN_FOLDER_ACTION, input_event)
	
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_0
	InputMap.add_action(_DEBUG_OPTION_ACTION + "0")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "0", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_1
	InputMap.add_action(_DEBUG_OPTION_ACTION + "1")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "1", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_2
	InputMap.add_action(_DEBUG_OPTION_ACTION + "2")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "2", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_3
	InputMap.add_action(_DEBUG_OPTION_ACTION + "3")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "3", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_4
	InputMap.add_action(_DEBUG_OPTION_ACTION + "4")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "4", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_5
	InputMap.add_action(_DEBUG_OPTION_ACTION + "5")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "5", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_6
	InputMap.add_action(_DEBUG_OPTION_ACTION + "6")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "6", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_7
	InputMap.add_action(_DEBUG_OPTION_ACTION + "7")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "7", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_8
	InputMap.add_action(_DEBUG_OPTION_ACTION + "8")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "8", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_9
	InputMap.add_action(_DEBUG_OPTION_ACTION + "9")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "9", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_A
	InputMap.add_action(_DEBUG_OPTION_ACTION + "10")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "10", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_B
	InputMap.add_action(_DEBUG_OPTION_ACTION + "11")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "11", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_C
	InputMap.add_action(_DEBUG_OPTION_ACTION + "12")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "12", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_D
	InputMap.add_action(_DEBUG_OPTION_ACTION + "13")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "13", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_E
	InputMap.add_action(_DEBUG_OPTION_ACTION + "14")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "14", input_event)
	
	input_event = InputEventKey.new()
	input_event.keycode = KEY_F
	InputMap.add_action(_DEBUG_OPTION_ACTION + "15")
	InputMap.action_add_event(_DEBUG_OPTION_ACTION + "15", input_event)
