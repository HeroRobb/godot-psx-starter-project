class_name MovementComponent3D
extends Node

enum MOVEMENT_TYPES {
	SLIDE,
	COLLIDE,
}

@export var _body: CharacterBody3D
@export var _mesh_component: MeshComponent
@export_range(0.5, 50.0, 0.5) var max_speed: float = 2.0
@export_range(0.1, 20.0, 0.1) var acceleration: float = 1.0
@export_range(0.5, 20.0, 0.5) var friction: float = 10.0
@export var ground_gravity: float = -0.1
@export var air_gravity := -9.8
@export var movement_type: MOVEMENT_TYPES = MOVEMENT_TYPES.SLIDE

var velocity: Vector3 = Vector3.ZERO
var speed_multiplier: float = 1.0

var _stopped: bool = false

@onready var _stopped_timer: Timer = $StoppedTimer


func _ready() -> void:
	assert(_body, "MovementComponent3D has no physics body set.")


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)


func move(direction: Vector3, delta: float):
	var max_velocity: Vector3 = max_speed * direction
	velocity = _body.velocity.lerp(max_speed * direction * delta, acceleration * delta)
	_body.velocity = velocity
	return _apply_velocity()


func move_to(target_location: Vector3, delta: float):
	if not _body:
		return
	
	if _stopped:
		velocity = Vector3.ZERO
	else:
		velocity = _body.velocity
	
	var direction = _body.global_position.direction_to(target_location)
	var weight: float
	
	if _body.global_position.distance_squared_to(target_location) < 0.01:
		weight = friction
	else:
		weight = acceleration
	
	_body.velocity = lerp(_body.velocity, max_speed * direction * speed_multiplier, weight * delta)
	
	if _mesh_component:
		_mesh_component.turn(velocity, delta)
	
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
	if movement_type == MOVEMENT_TYPES.SLIDE:
		_body.move_and_slide()
	elif movement_type == MOVEMENT_TYPES.COLLIDE:
		return _body.move_and_collide(_body.velocity)


func _apply_gravity(delta: float) -> void:
	var current_gravity = ground_gravity if _body.is_on_floor() else air_gravity
	_body.velocity.y += delta * current_gravity
