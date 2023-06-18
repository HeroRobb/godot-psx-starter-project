class_name MadeWithToolsCredit
extends Control


signal animation_finished()

@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func play_animation() -> void:
	_animation_player.play("godot_cmy_join")
	await _animation_player.animation_finished
	animation_finished.emit()
