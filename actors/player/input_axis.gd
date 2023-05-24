extends Node
# Updates input axis directions based checked input actions

const AXIS_LENGTH_MIN := -1
const AXIS_LENGTH_MAX := 1

@export var _up_action := "ui_up"
@export var _down_action := "ui_down"
@export var _left_action := "ui_left"
@export var _right_action := "ui_right"

var fake_direction: Vector2 : set = set_fake_direction  # nullable Vector2
var _up := 0.0
var _down := 0.0
var _left := 0.0
var _right := 0.0


func _unhandled_input(event: InputEvent):
	if event.is_action_type():
		if event.is_action(self._up_action):
			self._up = event.get_action_strength(self._up_action)
		if event.is_action(self._down_action):
			self._down = event.get_action_strength(self._down_action)
		if event.is_action(self._left_action):
			self._left = event.get_action_strength(self._left_action)
		if event.is_action(self._right_action):
			self._right = event.get_action_strength(self._right_action)


func get_raw_direction() -> Vector2:
	return (
		self.fake_direction
		if self.fake_direction != null
		else Vector2(self._right - self._left, self._down - self._up)
	)


# Sets `fake_direction` to `direction` if `direction` is a `Vector2`, otherwise `null` 
func set_fake_direction(direction):
	fake_direction = (
		Vector2(
			clamp(direction.x, AXIS_LENGTH_MIN, AXIS_LENGTH_MAX), clamp(direction.y, AXIS_LENGTH_MIN, AXIS_LENGTH_MAX)
		)
		if direction is Vector2
		else null
	)
