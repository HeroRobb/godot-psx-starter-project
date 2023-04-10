class_name MovementComponent
extends Node

enum MOVEMENT_TYPES {
	SLIDE,
	COLLIDE,
}

@export var body_path: NodePath
@export var mesh_component_path: NodePath
@export_range(3.0, 10.0, 0.1) var max_speed: float = 8.0
@export_range(0.1, 1.0, 0.05) var acceleration: float = .5
@export var ground_gravity: float = -0.1
@export var air_gravity := -9.8
@export var movement_type: MOVEMENT_TYPES = MOVEMENT_TYPES.SLIDE

var velocity: Vector3 = Vector3.ZERO
var speed_multiplier: float = 1.0

var _stopped: bool = false
var _body: CharacterBody3D
var _mesh_component: MeshComponent

@onready var _stopped_timer: Timer = $StoppedTimer


func _ready() -> void:
	assert(body_path)
	_body = get_node(body_path)
	
	if mesh_component_path:
		_mesh_component = get_node(mesh_component_path)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)


func move(target_location: Vector3, delta: float):
	if not _body:
		return
	
	if _stopped:
		velocity = Vector3.ZERO
	else:
		velocity = _body.velocity
	
	var direction = _body.global_position.direction_to(target_location)
	
	_body.velocity = lerp(_body.velocity, max_speed * direction * speed_multiplier, acceleration * delta)
	
	if _mesh_component:
		_mesh_component.turn(velocity, delta)
	
	if movement_type == MOVEMENT_TYPES.SLIDE:
		_body.move_and_slide()
	elif movement_type == MOVEMENT_TYPES.COLLIDE:
		return _body.move_and_collide(_body.velocity)


func stop(length_seconds: float = 1.0) -> void:
	if not _body:
		return
	
	if _stopped:
		return
	
	_stopped = true
	_stopped_timer.start(length_seconds)
	
	await(_stopped_timer.timeout)
	
	_stopped = false


func _apply_gravity(delta: float) -> void:
	var current_gravity = ground_gravity if _body.is_on_floor() else air_gravity
	_body.velocity.y += delta * current_gravity
