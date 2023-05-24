extends CharacterBody2D


@onready var _navigation_component: NavigationComponent2D = $NavigationComponent2D
@onready var _movement_component: MovementComponent2D = $MovementComponent2D
@onready var _health_component: HealthComponent = $HealthComponent
@onready var _sprite_component: SpriteComponent = $SpriteComponent


func _ready():
	_navigation_component.target_node = get_tree().get_first_node_in_group("player")
	_connect_signals()


func _take_damage(_damage_amount: int) -> void:
	_movement_component.stop()
	_sprite_component.flash(0.5)


func _die() -> void:
	_navigation_component.disable()
	remove_from_group("enemies")
	_sprite_component.play_animation(SpriteComponent.ANIMATIONS.DIE)
	await _sprite_component.animation_finished
	queue_free()


func _connect_signals() -> void:
	_health_component.damage_taken.connect(_take_damage)
	_health_component.health_reached_zero.connect(_die)
