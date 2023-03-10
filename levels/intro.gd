extends Control


@export var next_scene_id: Global.LEVELS = Global.LEVELS.MAIN_MENU
@export var content_warning_sound: Global.SFX = Global.SFX.NJB

var _intro_skipped: bool = false

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _held_input_check: HeldInputCheck = $HeldInputCheck


func _ready():
	_held_input_check.input_held.connect(_skip_intro)
	_show_intro()


func _skip_intro() -> void:
	if _intro_skipped:
		return
	_intro_skipped = true
	_animation_player.stop()
	_animation_player.animation_finished.emit()
	SoundManager.stop_sfx()
	SignalManager.change_scene_needed.emit(next_scene_id)


func _show_intro() -> void:
	_animation_player.play("made_by_me")
	await _animation_player.animation_finished
	if _intro_skipped:
		_skip_intro()
		return
	SoundManager.play_sfx(Global.SFX.NJB)
	_animation_player.play("content_warning")
	await _animation_player.animation_finished
	if _intro_skipped:
		_skip_intro()
		return
	SignalManager.change_scene_needed.emit(next_scene_id)
