@tool
extends Launcher

## This is an example of how to extend the launcher and override the necessary
## functions.

var _selection_made: bool = false


## This is the function that will be called if the top selection is chosen.
func handle_first_selection() -> void:
	if _selection_made: return
	
	SignalManager.set_window_mode.emit(Global.WINDOW_MODES.FULLSCREEN)
	_selection_made = true


## This is the function that will be called if the middle selection is chosen.
func handle_second_selection() -> void:
	if _selection_made: return
	
	SignalManager.set_window_mode.emit(Global.WINDOW_MODES.WINDOWED_MED)
	_selection_made = true
