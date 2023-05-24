class_name EndScreen
extends CanvasLayer


const LOSS_TITLE_TEXT: String = "You livedn't"
const LOSS_DESCRIPTION_TEXT: String = "What happened?"
const WIN_TITLE_TEXT: String = "Victory achieved lmao"
const WIN_DESCRIPTION_TEXT: String = "A winner is you!"

@onready var _title_label: Label = %TitleLabel
@onready var _description_label: Label = %DescriptionLabel
@onready var _restart_button: Button = %RestartButton
@onready var _quit_button: Button = %QuitButton


func _ready():
	get_tree().paused = true
	_restart_button.pressed.connect(_on_restart_button_pressed)
	_quit_button.pressed.connect(_on_quit_button_pressed)


func set_win() -> void:
	_title_label.text = WIN_TITLE_TEXT
	_description_label.text = WIN_DESCRIPTION_TEXT


func set_loss() -> void:
	_title_label.text = LOSS_TITLE_TEXT
	_description_label.text = LOSS_DESCRIPTION_TEXT


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	SignalManager.time_scale_change_requested.emit(1, 0)
	SoundManager.stop_music()
	SoundManager.stop_ambience()
	await get_tree().process_frame
	SignalManager.change_scene_requested.emit(Global.LEVELS.TEST)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
