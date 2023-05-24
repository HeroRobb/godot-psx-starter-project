class_name ArenaTimeManager
extends Node


signal arena_difficulty_changed(new_difficulty: int)

@export_range(5, 600, 1) var _time_limit_seconds: float = 180
@export_range(5, 20, 1) var _difficulty_interval: float = 5
@export var _end_screen_scene: PackedScene

var _arena_difficulty: int = 0 : set = _set_arena_difficulty

@onready var _timer: Timer = $Timer


func _ready():
	_timer.timeout.connect(_on_timer_timeout)
	_timer.wait_time = _time_limit_seconds
	_timer.start()


func _process(delta: float) -> void:
	var next_time_target: float = _timer.wait_time - ( (_arena_difficulty + 1) * _difficulty_interval )
	
	if _timer.time_left > next_time_target: return
	
	_arena_difficulty += 1


func get_time_elapsed() -> float:
	return _timer.wait_time - _timer.time_left


func _set_arena_difficulty(new_arena_difficulty: int) -> void:
	_arena_difficulty = new_arena_difficulty
	
	arena_difficulty_changed.emit(_arena_difficulty)


func _on_timer_timeout() -> void:
	var end_screen_instance: EndScreen = _end_screen_scene.instantiate()
	add_child(end_screen_instance)
	end_screen_instance.set_win()
