class_name MovementComponent2D
extends Node

enum MOVEMENT_TYPES {
	SIDE_SCROLLING,
	TOP_DOWN,
}

signal is_moving_changed(new_is_moving: bool)

@export var _body: CharacterBody2D
@export var _sprite_component: SpriteComponent
@export_range(0.5, 100.0, 0.5) var max_speed: float = 100.0
@export_range(0.1, 20.0, 0.1) var acceleration: float = 10.0
@export_range(0.5, 20.0, 0.5) var friction: float = 15.0
@export var ground_gravity: float = -0.1
@export var air_gravity := -9.8
@export var movement_type: MOVEMENT_TYPES = MOVEMENT_TYPES.SIDE_SCROLLING

var velocity: Vector2 = Vector2.ZERO
var speed_multiplier: float = 1.0

var _stopped: bool = false
var _is_moving: bool = false : set = _set_is_moving

@onready var _stopped_timer: Timer = $StoppedTimer


func _ready() -> void:
	assert(_body, "MovementComponent2D has no physics body.")


func _physics_process(delta: float) -> void:
	if movement_type == MOVEMENT_TYPES.SIDE_SCROLLING:
		_apply_gravity(delta)
	
	_is_moving = velocity.length_squared() > 0.5


func move(direction: Vector2, delta: float):
	var max_velocity: Vector2 = max_speed * direction
	velocity = _body.velocity.lerp(max_speed * direction, acceleration * delta)
	_body.velocity = velocity
	return _apply_velocity()


func move_to(target_location: Vector2, delta: float):
	if not _body:
		return
	
	if _stopped:
		velocity = Vector2.ZERO
	else:
		velocity = _body.velocity
	
	var direction = _body.global_position.direction_to(target_location)
	var weight: float
	
	if _body.global_position.distance_squared_to(target_location) < 0.01:
		_sprite_component.moving = false
		weight = friction
	else:
		_sprite_component.moving = true
		weight = acceleration
	
	_body.velocity = lerp(_body.velocity, max_speed * direction * speed_multiplier, weight * delta)
	
	if _sprite_component:
		_sprite_component.face(velocity.normalized())
	
	return _apply_velocity()


func stop(length_seconds: float = 1.0) -> void:
	if not _body:
		return
	
	if _stopped:
		return
	
	_stopped = true
	_stopped_timer.start(length_seconds)
	
	await(_stopped_timer.timeout)
	
	_stopped = false


func _apply_velocity():
	_body.move_and_slide()
#	if movement_type == MOVEMENT_TYPES.SIDE_SCROLLING:
#		_body.move_and_slide()
#	elif movement_type == MOVEMENT_TYPES.COLLIDE:
#		return _body.move_and_collide(_body.velocity)


func _apply_gravity(delta: float) -> void:
	var current_gravity = ground_gravity if _body.is_on_floor() else air_gravity
	_body.velocity.y += delta * current_gravity


func _set_is_moving(new_is_moving) -> void:
	if _is_moving == new_is_moving:
		return
	
	_is_moving = new_is_moving
	is_moving_changed.emit(_is_moving)
