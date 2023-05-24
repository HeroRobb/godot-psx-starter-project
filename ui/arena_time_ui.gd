extends CanvasLayer


@export var _arena_time_manager: ArenaTimeManager

@onready var _time_label: Label = %TimeLabel


func _process(delta):
	if not _arena_time_manager:
		return
	
	var time_elapsed: float = _arena_time_manager.get_time_elapsed()
	var formatted_time: String = _format_time_to_string(time_elapsed)
	_time_label.text = formatted_time


func _format_time_to_string(seconds: float) -> String:
	var minutes: int = floori(seconds / 60)
	var remaining_seconds: int = floori( seconds - (minutes * 60) )
	
	var formatted_string: String = "%02d:%02d" % [minutes, remaining_seconds]
	
	return formatted_string
