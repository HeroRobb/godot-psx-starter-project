class_name ExperienceManager
extends Node


signal experience_changed(current_experience: int, experience_to_next_level: int)
signal level_up_achieved(new_level: int)

@export var _debug_level_up: bool = false

var _current_experience: int = 0
var _current_level: int = 1
var _experience_to_next_level: int = 5


func _ready():
	_connect_signals()
	
	if _debug_level_up:
		_experience_to_next_level = 1


func add_experience(amount_to_add: int) -> void:
	_current_experience += amount_to_add
	experience_changed.emit(_current_experience, _experience_to_next_level)
	
	if _current_experience < _experience_to_next_level: return
	
	_current_experience -= _experience_to_next_level
	_level_up()


func _level_up() -> void:
	_current_level += 1
	if _debug_level_up:
		_experience_to_next_level = 1
		_current_experience = 0
	else:
		_experience_to_next_level = floori(_current_level / 2.0) + (_current_level * 5)
	
	experience_changed.emit(_current_experience, _experience_to_next_level)
	level_up_achieved.emit(_current_level)


func _connect_signals() -> void:
	SignalManager.experience_gained.connect(add_experience)
