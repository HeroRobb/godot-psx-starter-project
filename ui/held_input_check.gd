class_name HeldInputCheck
extends Control

## This node emits a signal if an action is held for an amount of time.
##
## Set [member skip_action_name] and [member held_seconds] in the editor. This
## Node will show a progress bar while the action is held. After held_seconds,
## the progress bar will be filled and this node will emit [signal input_held].


signal input_held()

const _HELD_RATE = 12

@export var skip_action_name: String = "ui_accept"
@export var held_seconds: float = 2

@onready var _progress_bar: ProgressBar = $HBoxContainer/VBoxContainer/ProgressBar


func _ready():
	_progress_bar.max_value = held_seconds * 20
	hide()


func _process(delta):
	if Input.is_action_just_pressed(skip_action_name):
		show()
	
	if Input.is_action_pressed(skip_action_name):
		_progress_bar.value += _HELD_RATE * delta
	
	elif Input.is_action_just_released(skip_action_name):
		hide()
		_progress_bar.value = 0
	
	if _progress_bar.value == _progress_bar.max_value:
		input_held.emit()
