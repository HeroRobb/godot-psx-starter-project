class_name UIEnemiesDefeated
extends Control


signal defeated_enemy_count_reached()

const ACTIVATION_TIME: float = 0.5
const DEACTIVATION_TIME: float = 1.0

var _counting_enemies: bool = false : set = _set_counting_enemies
var _defeated_enemies_count: int = 0 : set = _set_defeated_enemies_count
var _total_enemies_count: int = 0 : set = _set_total_enemies_count
var _inactive_position: Vector2 = Vector2(0, -24)

@onready var _enemies_defeated_count_label: Label = %EnemiesDefeatedCountLabel
@onready var _total_enemies_count_label: Label = %TotalEnemiesCountLabel
@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	SignalManager.enemy_died.connect(_on_enemy_died)
	hide()


func start_count(total_enemies_to_be_defeated: int) -> void:
	_total_enemies_count = total_enemies_to_be_defeated
	_defeated_enemies_count = 0
	_counting_enemies = true


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


func _set_counting_enemies(new_counting_enemies: bool) -> void:
	_counting_enemies = new_counting_enemies
	
	if _counting_enemies:
		_activate()
		return
	
	_deactivate()


func _set_defeated_enemies_count(new_defeated_enemies_count: int) -> void:
	_defeated_enemies_count = clamp(new_defeated_enemies_count, 0, _total_enemies_count)
	
	_enemies_defeated_count_label.text = str(_defeated_enemies_count)
	
	if _defeated_enemies_count == _total_enemies_count:
		_counting_enemies = false
		defeated_enemy_count_reached.emit()


func _set_total_enemies_count(new_total_enemies_count: int) -> void:
	_total_enemies_count = new_total_enemies_count
	
	_total_enemies_count_label.text = str(_total_enemies_count)


func _on_enemy_died(enemy_name: String) -> void:
	if _counting_enemies:
		_defeated_enemies_count += 1
