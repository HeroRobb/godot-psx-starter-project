@tool
class_name SelectionContainer
extends VBoxContainer

## This node is intended to be used in conjunction with [MenuSelection] to
## create in game menus.
##
## This is intended to have multiple children of the [MenuSelection] class.


signal option_confirmed(option)
signal slider_value_changed(value, id)

const TRANS_DURATION = 0.9
const _OPAQUE_COLOR = Color(1, 1, 1, 1)
const _CLEAR_COLOR = Color(1, 1, 1, 0)
const _CANCEL_OPTIONS = ["Exit", "Back"]

@export var menu_available: bool = true: set = set_menu_available
@export var title: String = "Menu Title": set = set_title
@export_range(8, 64) var title_font_size: int = 16 : set = set_title_font_size
@export_range(8, 64) var selection_font_size: int = 16 : set = set_selection_font_size
@export var ui_change_sound_id: Global.SFX = Global.SFX.BLIP
@export var ui_confirm_sound_id: Global.SFX = Global.SFX.BLIP
@export var ui_cancel_sound_id: Global.SFX = Global.SFX.BLIP

var options: Array
var currently_selected_option: MenuSelection

var _selected_option_index: int
var _readied: bool = false

@onready var _title_label: Label = $TitleLabel


func _ready() -> void:
	for child in get_children():
		if not child is MenuSelection:
			continue
		
		var menu_selection: MenuSelection = child
		
		menu_selection.set_font_size(selection_font_size)
		menu_selection.option_index = options.size()
		options.append(menu_selection)
		menu_selection.moused_over.connect(_on_option_moused_over)
		menu_selection.gui_input.connect(_on_option_gui_input)
		menu_selection.slider_value_changed.connect(_on_slider_value_changed)
	
	_select(0, false)
	if not menu_available:
		modulate = _CLEAR_COLOR
	_readied = true


func _input(event: InputEvent) -> void:
	if not menu_available:
		return
	
	if event.is_action_pressed("ui_up"):
		select_previous()
	elif event.is_action_pressed("ui_down"):
		select_next()
	elif event.is_action_pressed("ui_right"):
		action_right()
	elif event.is_action_pressed("ui_left"):
		action_left()
	elif event.is_action_pressed("ui_accept"):
		confirm_currently_selected_option()


func set_title(new_title: String) -> void:
	if not _readied:
		await self.ready
	title = new_title
	_title_label.text = title


func set_menu_available(new_menu_available: bool) -> void:
	if Engine.is_editor_hint() or menu_available == new_menu_available:
		return
	menu_available = new_menu_available
	var end_modulate: Color
	if menu_available:
		modulate = _CLEAR_COLOR
		end_modulate = _OPAQUE_COLOR
		show()
	else:
		modulate = _OPAQUE_COLOR
		end_modulate = _CLEAR_COLOR
	
	var trans_tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	trans_tween.tween_property(self, "modulate", end_modulate, TRANS_DURATION)
	if not menu_available:
		trans_tween.tween_callback(hide)


func select_next() -> void:
	_select(_selected_option_index + 1)


func select_previous() -> void:
	_select(_selected_option_index - 1)


func confirm_currently_selected_option() -> void:
	_confirm_option(currently_selected_option)


func action_left() -> void:
	if not options[_selected_option_index].horizontal_input:
		return
	
	options[_selected_option_index].action_left()


func action_right() -> void:
	if not options[_selected_option_index].horizontal_input:
		return
	
	options[_selected_option_index].action_right()


func set_title_font_size(new_title_font_size: int) -> void:
	title_font_size = new_title_font_size
	
	if not _readied:
		await ready
	
	_title_label.add_theme_font_size_override("font_size", title_font_size)


func set_selection_font_size(new_selection_font_size: int) -> void:
	selection_font_size = new_selection_font_size
	
	for child in get_children():
		if not child is MenuSelection:
			continue
		
		var menu_selection: MenuSelection = child
		menu_selection.set_font_size(selection_font_size)


func _confirm_option(option) -> void:
	menu_available = false
	SoundManager.play_sfx(ui_confirm_sound_id)
	option_confirmed.emit(option.selection_name)


func _select(option_index: int, loud: bool = true) -> void:
	if option_index < 0:
		_selected_option_index = options.size() - 1
	elif option_index >= options.size():
		_selected_option_index = 0
	else:
		_selected_option_index = option_index
	
	if currently_selected_option:
		currently_selected_option.deselect()
	currently_selected_option = options[_selected_option_index]
	if loud:
		SoundManager.play_sfx(ui_change_sound_id)
	currently_selected_option.select()


func _deselect_all() -> void:
	for option in options:
		option.deselect()


func _on_option_moused_over(moused_index: int) -> void:
	_select(moused_index)


func _on_option_gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return
	if not menu_available:
		return
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		confirm_currently_selected_option()


func _on_slider_value_changed(new_value: float, id: String) -> void:
	slider_value_changed.emit(new_value, id)
