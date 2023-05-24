extends Node


const RANDOM_SPAWN_OFFSET: float = 6.0

@export var max_range: int = 35
@export var sword_ability: PackedScene
@export var damage_source: DamageSource

var base_cooldown_seconds: float = 1.5
var extra_hits: int = 0

@onready var _player: Node2D = get_tree().get_first_node_in_group("player")
@onready var _timer: Timer = $Timer


func _ready():
	_connect_signals()
	_timer.wait_time = base_cooldown_seconds


func _spawn_sword() -> void:
	var enemies_array: Array = get_tree().get_nodes_in_group("enemies")
	var filtered_enemies: Array = enemies_array.filter(_enemy_check)
	
	if filtered_enemies.is_empty():
		return
	
	filtered_enemies.sort_custom(_sort_enemy_by_closest)
	var closest_enemy: Node2D = filtered_enemies.pop_front()
	var sword_instance: SwordAbility = sword_ability.instantiate()
	var foreground_container: Node = get_tree().get_first_node_in_group("foreground_container")
	
	if foreground_container:
		foreground_container.add_child(sword_instance)
	else:
		get_parent().add_child(sword_instance)
	
	sword_instance.set_damage_source(damage_source)
	sword_instance.add_hits(extra_hits)
	sword_instance.global_position = closest_enemy.global_position
	sword_instance.global_position += Vector2.RIGHT.rotated(randf_range(0, TAU)) * RANDOM_SPAWN_OFFSET
	
	var direction_to_enemy: Vector2 = closest_enemy.global_position - sword_instance.global_position
	sword_instance.rotation = direction_to_enemy.angle()


func _enemy_check(enemy: Node2D) -> bool:
	return enemy.global_position.distance_squared_to(_player.global_position) < pow(max_range, 2)


func _sort_enemy_by_closest(enemy_a: Node2D, enemy_b: Node2D) -> bool:
	var a_distance_to_player: float = enemy_a.global_position.distance_squared_to(_player.global_position)
	var b_distance_to_player: float = enemy_b.global_position.distance_squared_to(_player.global_position)
	
	return a_distance_to_player < b_distance_to_player


func _reduce_cooldown_percentage(percentage_reduction: float) -> void:
	var ratio_reduction: float = percentage_reduction / 100.0
	_timer.wait_time *= (1 - ratio_reduction)
	_timer.start()


func _connect_signals() -> void:
	_timer.timeout.connect(_on_timer_timeout)
	SignalManager.ability_upgrade_added.connect(_on_ability_upgrade_added)


func _on_timer_timeout() -> void:
	if not _player:
		return
	
	_spawn_sword()


func _on_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary) -> void:
	if not upgrade.id.begins_with("sword_"): return
	
	match upgrade.id:
		"sword_rate":
			_reduce_cooldown_percentage(10)
		"sword_damage":
			damage_source.damage += 1
		"sword_hits":
			extra_hits += 1
