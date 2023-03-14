@tool
class_name MenuSelection
extends HBoxContainer


signal moused_over(options_index)
signal slider_value_changed(new_value, id)

@export var selection_name: String = "" : set = set_selection_name
@export var horizontal_input: bool = false
@export var slider_sound_id: Global.SFX = Global.SFX.BLIP

var selected: bool = false : set = set_selected
var option_index: int

var _slider: HSlider

@onready var _label: Label = $SelectionLabel
@onready var _texture_rect: TextureRect = $SelectedContainer/SelectedRect


func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	set_selection_name(selection_name)
	
	for child in get_children():
		if child.has_method("set_parent"):
			child.parent = self
	
	_slider = get_node_or_null("SliderContainer/HSlider")
	if _slider:
		_slider.value_changed.connect(_on_slider_value_changed)
	
	deselect()


func select() -> void:
	set_selected(true)


func deselect() -> void:
	set_selected(false)


func action_left() -> void:
	if not horizontal_input or _slider == null:
		return
	
	SoundManager.play_sfx(slider_sound_id)
	_slider.value -= _slider.step


func action_right() -> void:
	if not horizontal_input or _slider == null:
		return
	
	SoundManager.play_sfx(slider_sound_id)
	_slider.value += _slider.step


func set_selection_name(new_name: String) -> void:
	selection_name = new_name
	if _label:
		_label.text = selection_name


func set_selected(new_selected: bool) -> void:
	selected = new_selected
	if _texture_rect:
		_texture_rect.visible = selected


func set_font_size(new_font_size: int) -> void:
	_label.add_theme_font_size_override("font_size", new_font_size)


func _on_mouse_entered() -> void:
	moused_over.emit(option_index)


func _on_slider_value_changed(new_value: float) -> void:
	slider_value_changed.emit(new_value, selection_name)
