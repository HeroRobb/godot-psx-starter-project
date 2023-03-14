extends Control


const _DEVELOPER_CREDIT_TEXT = "A game by %s"
const _QUOTE_ATTRIBUTION_TEXT = "- %s"


@export var next_level_id: Global.LEVELS = Global.LEVELS.MAIN_MENU
@export var content_warning_sound: Global.SFX = Global.SFX.NJB
@export var developer_name: String = "Hero Robb"
@export_multiline var content_warning: String = "This game contains themes of violence and abuse that some may find disturbing."
@export var show_quote: bool = true
@export_multiline var opening_quote: String = "\"No live organism can continue for long to exist sanely under conditions of absolute reality\""
@export var quote_attribution: String = "Shirley Jackson, The Haunting of Hill House"

var _intro_skipped: bool = false

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _held_input_check: HeldInputCheck = $HeldInputCheck
@onready var _developer_credit_label: Label = %DeveloperCreditLabel
@onready var _content_warning_label: Label = %ContentWarningLabel
@onready var _quote_label: Label = %QuoteLabel
@onready var _quote_credit_label: Label = %QuoteCreditLabel


func _ready():
	_held_input_check.input_held.connect(_skip_intro)
	_developer_credit_label.text = _DEVELOPER_CREDIT_TEXT % developer_name
	_content_warning_label.text = content_warning
	_quote_label.text = opening_quote
	_quote_credit_label.text = _QUOTE_ATTRIBUTION_TEXT % quote_attribution
	_show_intro()


func _skip_intro() -> void:
	if _intro_skipped:
		return
	_intro_skipped = true
	_animation_player.stop()
	_animation_player.animation_finished.emit()
	SoundManager.stop_sfx()
	SignalManager.change_scene_needed.emit(next_level_id)


func _show_intro() -> void:
	_animation_player.play("made_by_me")
	await _animation_player.animation_finished
	if _intro_skipped:
		_skip_intro()
		return
	
	_animation_player.play("made_with_tools")
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
	
	if show_quote:
		_animation_player.play("quote")
		await _animation_player.animation_finished
		if _intro_skipped:
			_skip_intro()
			return
	
	SignalManager.change_scene_needed.emit(next_level_id)
