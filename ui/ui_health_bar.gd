extends PanelContainer


enum HEALTH_OWNERS {PLAYER, ENEMY}

const ENEMY_UI_RESET_TIME = 7
const HEAL_FLASH_AMOUNT = 8

@export var health_owner: HEALTH_OWNERS = HEALTH_OWNERS.PLAYER

var _flash_amount := 0

@onready var _container: VBoxContainer = $MarginContainer/VBoxContainer
@onready var _label: Label = $MarginContainer/VBoxContainer/Label
@onready var _health_bar: HealthBar = $MarginContainer/VBoxContainer/HealthBar
@onready var _enemy_ui_timer: Timer = $EnemyUITimer
@onready var _flash_timer: Timer = $FlashTimer


func _ready() -> void:
	_flash_timer.timeout.connect(_on_flash_timer_timeout)
	
	if health_owner == HEALTH_OWNERS.PLAYER:
		set_health_name("Player")
		SignalManager.player_health_changed.connect(_on_player_health_changed)
		_enemy_ui_timer.queue_free()
	elif health_owner == HEALTH_OWNERS.ENEMY:
		SignalManager.enemy_health_changed.connect(_on_enemy_health_changed)
		_container.hide()
		_enemy_ui_timer.timeout.connect(_on_enemy_ui_timer_timeout)
		SignalManager.change_scene_requested.connect(_on_change_scene_requested)


func set_health_name(health_name: String) -> void:
	_label.text = health_name


func heal_effect() -> void:
	_flash_timer.start()


func _on_player_health_changed(health: int, max_health: int) -> void:
	_health_bar.ensure_scale()
	_health_bar.show()
	_health_bar.set_health_bar(health, max_health)


func _on_enemy_health_changed(enemy_name: String, health: int, max_health: int) -> void:
	set_health_name(enemy_name)
	_health_bar.set_health_bar(health, max_health)
	_health_bar.ensure_scale()
	_health_bar.show()
	_container.show()
	_enemy_ui_timer.start(ENEMY_UI_RESET_TIME)


func _clear_enemy_health_bar() -> void:
	_container.hide()


func _on_enemy_ui_timer_timeout() -> void:
	_clear_enemy_health_bar()


func _on_change_scene_requested(new_scene_id: int, silent: bool = false, black_out: bool = false) -> void:
	_clear_enemy_health_bar()


func _on_player_healed() -> void:
	heal_effect()


func _on_flash_timer_timeout() -> void:
	if _flash_amount >= HEAL_FLASH_AMOUNT:
		_flash_timer.stop()
		_flash_amount = 0
		_health_bar.visible = true
		return
	
	_flash_amount += 1
	_health_bar.visible = !_health_bar.visible
