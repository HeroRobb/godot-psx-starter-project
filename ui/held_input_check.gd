class_name HeldInputCheck
extends Control


signal input_held()

const _HELD_RATE = 12

@export var _skip_action_name: String = "ui_accept"
@export var _held_time: float = 2

@onready var _progress_bar: ProgressBar = $HBoxContainer/VBoxContainer/ProgressBar


func _ready():
	_progress_bar.max_value = _held_time * 20
	hide()


func _process(delta):
	if Input.is_action_just_pressed(_skip_action_name):
		show()
	
	if Input.is_action_pressed(_skip_action_name):
		_progress_bar.value += _HELD_RATE * delta
	
	elif Input.is_action_just_released(_skip_action_name):
		hide()
		_progress_bar.value = 0
	
	if _progress_bar.value == _progress_bar.max_value:
		input_held.emit()
