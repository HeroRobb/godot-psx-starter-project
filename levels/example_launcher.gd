extends Launcher


func handle_first_option() -> void:
	SignalManager.set_window_mode.emit(Global.WINDOW_MODES.FULLSCREEN)


func handle_second_option() -> void:
	SignalManager.set_window_mode.emit(Global.WINDOW_MODES.FULLSCREEN)
