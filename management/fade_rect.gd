class_name FadeRect
extends ColorRect

## A [ColorRect] that is used to fade the screen to whatever color you want.
##
## This node is predominatly used in HR PSX to fade the screen to black between
## scene changes.


## This signal is emited when the animation from [method fade_in] or
## [method fade_out] is finished.
signal fade_finished()

## The color that will be faded to in [method fade_out] or faded from in
## [method fade_in].
@export var default_fade_color: Color = Color.BLACK

@onready var _animation_player: AnimationPlayer = $TransAnimationPlayer


func _ready() -> void:
	_animation_player.animation_finished.connect(_on_trans_animation_player_animation_finished)


func fade_in(fade_seconds: float = 1.0) -> void:
	_set_animation_speed(fade_seconds)
	_animation_player.play("fade_in")


func fade_out(fade_seconds: float = 0.5, color: Color = default_fade_color) -> void:
	modulate = color
	_set_animation_speed(fade_seconds)
	_animation_player.play("fade_out")


func _set_animation_speed(seconds: float) -> void:
	var clamped_seconds = clampf(seconds, 0.05, 20)
	_animation_player.speed_scale /= clamped_seconds


func _on_trans_animation_player_animation_finished(_animation_name: String) -> void:
	_animation_player.speed_scale = 1
	fade_finished.emit()
