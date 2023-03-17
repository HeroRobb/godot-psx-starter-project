@tool
extends Launcher

## This is an example of how to extend the launcher and override the necessary
## functions.


## This is the function that will be called if the top selection is chosen.
func handle_first_selection() -> void:
	SignalManager.set_window_mode.emit(Global.WINDOW_MODES.FULLSCREEN)


## This is the function that will be called if the middle selection is chosen.
func handle_second_selection() -> void:
	SignalManager.set_window_mode.emit(Global.WINDOW_MODES.WINDOWED_MED)
