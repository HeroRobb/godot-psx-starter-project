class_name Intro
extends Control

## An intro scene intended to be used before the main menu of your game
##
## If you use this scene, it will credit yourself, the Godot engine, and HR PSX.
## You should change the exported variables in the editor to make customize it
## for your game by using the scene it will transition to, your name, any content
## warning you might need, and a relevant quote to set the tone.


const _DEVELOPER_CREDIT_TEXT = "A game by %s"
const _QUOTE_ATTRIBUTION_TEXT = "- %s"

## This is the id (from the LEVELS enum in res://management/global.gd) of the
## scene that will be transitioned to after the intro has finished or was skipped.
@export var next_level_id: Global.LEVELS = Global.LEVELS.MAIN_MENU
## This is what you will be credited as when the developer credit plays ("A
## game by [developer_name] )
@export var developer_name: String = "Hero Robb"
## The content warning will be skipped if this is false. Don't be a jerk and
## skip the content warning just because you don't feel like it.
@export var show_content_warning: bool = true
## This is the id (from the SFX enum in res://management/global.gd) of the sfx
## that will be played while the content warning is shown
@export var content_warning_sound: Global.SFX = Global.SFX.NJB
## This is what will be shown during the content warning. This is generally
## what I put in my games with slight variations so I think this is an ok
## default if you're not sure what to put.
@export_multiline var content_warning: String = "This game contains themes of violence and abuse that some may find disturbing."
## The quote will be skipped if this is false. You can skip a quote, but I
## think they're pretty cool.
@export var show_quote: bool = true
## This is what will be shown during the quote section of the intro. If you use
## the default font and size from HR PSX, this is about the limit of how long
## the quote and attribution can be before it's too long to fit. Note that this
## is only the quote itself and the attribution of who said the quote and what
## it's from should be in quote_attribution.
@export_multiline var opening_quote: String = "\"No live organism can continue for long to exist sanely under conditions of absolute reality\""
## This is who said the quote and where it's from.
@export var quote_attribution: String = "Shirley Jackson, The Haunting of Hill House"

var _intro_skipped: bool = false

@onready var _animation_player: AnimationPlayer = $AnimationPlayer
@onready var _held_input_check: HeldInputCheck = $HeldInputCheck
@onready var _developer_credit_label: Label = %DeveloperCreditLabel
@onready var _made_with_tools: MadeWithToolsCredit = $MadeWithTools
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
	SignalManager.change_scene_requested.emit(next_level_id)


func _show_intro() -> void:
	_animation_player.play("made_by_me")
	await _animation_player.animation_finished
	if _intro_skipped:
		_skip_intro()
		return
	
#	_animation_player.play("made_with_tools")
#	await _animation_player.animation_finished
	_made_with_tools.play_animation()
	await _made_with_tools.animation_finished
	if _intro_skipped:
		_skip_intro()
		return
	SoundManager.play_sfx(Global.SFX.NJB)
	
	if show_content_warning:
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
	
	SignalManager.change_scene_requested.emit(next_level_id)
