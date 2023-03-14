@tool
extends Launcher


func handle_first_selection() -> void:
	SignalManager.set_window_mode.emit(Global.WINDOW_MODES.FULLSCREEN)


func handle_second_selection() -> void:
	SignalManager.set_window_mode.emit(Global.WINDOW_MODES.FULLSCREEN)
