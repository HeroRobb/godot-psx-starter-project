extends Node
# Handles capturing and releasing of the mouse, primarily through user input.
# Designed to be used to intercept mouse input before it reaches the player's character controller, in order to lessen responsibility.

signal mouse_grabbed(is_grabbed)

# The input action name to watch for triggering a release.
@export var _release_action_name := "release_mouse"

# Controls whether automatically grab focus checked `_ready()`.
# Typically, this is desired behavior.
@export var _should_grab_on_ready := true

# Forces mouse to be released when focus is lost.
# Useful for triggering callbacks, such as automatically displaying a pause screen when the player alt-tabs.
@export var _should_stay_released_on_refocus := true

var is_mouse_grabbed := false : get = get_mouse_grabbed, set = set_mouse_grabbed

func _ready():
	# setgets aren't called with onready
	if self._should_grab_on_ready and not OS.get_name() == "HTML5":
		self.is_mouse_grabbed = true


func _notification(what: int):
	var is_focus_lost := what == NOTIFICATION_APPLICATION_FOCUS_OUT
	if is_focus_lost and self._should_stay_released_on_refocus:
		self.is_mouse_grabbed = false


func _unhandled_input(_event: InputEvent):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and not self.is_mouse_grabbed:
		self.is_mouse_grabbed = true
		get_viewport().set_input_as_handled()

	elif Input.is_action_just_pressed(self._release_action_name) and self.is_mouse_grabbed:
		self.is_mouse_grabbed = false
		get_viewport().set_input_as_handled()


func set_mouse_grabbed(is_grabbed: bool):
	is_mouse_grabbed = is_grabbed
	emit_signal("mouse_grabbed", is_grabbed)
	_update_mouse_mode(is_grabbed)


func get_mouse_grabbed() -> bool:
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED


# Stub this to avoid side-effects in testing
func _update_mouse_mode(is_grabbed: bool):
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if is_grabbed else Input.MOUSE_MODE_VISIBLE)
