class_name UICountdownTimer
extends Control


signal countdown_finished()

const ACTIVATION_TIME: float = 0.5
const DEACTIVATION_TIME: float = 1.0

var running: bool = false

var _inactive_position: Vector2 = Vector2(0, -24)

@onready var _number_label: Label = $MarginContainer/HBoxContainer/TimeNumberLabel
@onready var _timer: Timer = $Timer
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	_timer.timeout.connect(_on_timer_timeout)
	hide()


func _process(delta: float) -> void:
	if running:
		var rounded_time = snapped(_timer.time_left, 0.01)
		_number_label.text = str(rounded_time)


func start(countdown_seconds: float) -> void:
	_timer.start(countdown_seconds)
	_activate()
	running = true


func _activate() -> void:
	_animation_player.play("RESET")
	position = _inactive_position
	show()
	var position_tween: Tween = create_tween()
	position_tween.tween_property(self, "position", Vector2.ZERO, ACTIVATION_TIME)
	position_tween.set_ease(Tween.EASE_IN_OUT)


func _deactivate() -> void:
	_animation_player.play("flash")
	await(_animation_player.animation_finished)
	var position_tween := create_tween()
	position_tween.tween_property(self, "position", _inactive_position, DEACTIVATION_TIME)
	position_tween.set_ease(Tween.EASE_IN_OUT)
	await position_tween.finished
	hide()


func _on_timer_timeout() -> void:
	running = false
	_number_label.text = "0.00"
	countdown_finished.emit()
	_deactivate()
