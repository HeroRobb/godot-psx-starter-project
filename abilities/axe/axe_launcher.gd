extends Node


@export var _axe_ability_scene: PackedScene
@export var _damage_source: DamageSource

var _player: Node2D
var _foreground_container: Node2D

@onready var _timer: Timer = $Timer


func _ready() -> void:
	_timer.timeout.connect(_on_timer_timeout)
	_player = get_tree().get_first_node_in_group("player")
	_foreground_container = get_tree().get_first_node_in_group("foreground_container")


func _on_timer_timeout() -> void:
	if not _player or not _foreground_container: return
	
	var axe_instance: AxeAbility = _axe_ability_scene.instantiate()
	_foreground_container.add_child(axe_instance)
	if _damage_source: axe_instance.set_damage_source(_damage_source)
	axe_instance.global_position = _player.global_position
