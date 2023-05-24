class_name TopDownActor
extends CharacterBody3D


enum DIRECTIONS {BOTTOM, RIGHT, TOP, LEFT}


const ANGULAR_ACCELERATION = 10.0
const ACCELERATION := .5
const AIR_GRAVITY = -9.8
const GROUND_GRAVITY = -0.1
const GROUND_ACCELERATION = 2.0
const FRICTION = 0.25

@export var max_speed = 10.0 # (float, 10.0, 25.0, 0.5)

var direction: Vector2

@onready var _mesh_container := $MeshContainer
@onready var _hitbox: Area3D = $Hitbox


func _calculate_gravity() -> void:
	velocity.y = GROUND_GRAVITY if is_on_floor() else AIR_GRAVITY


func _calculate_movement(delta: float) -> void:
	if direction.x != 0 or direction.y != 0:
		velocity.x = lerp(velocity.x, direction.x * max_speed, GROUND_ACCELERATION * delta)
		velocity.z = lerp(velocity.z, direction.y * max_speed, GROUND_ACCELERATION * delta)
		return

	velocity.x = lerp(velocity.x, 0.0, FRICTION)
	velocity.z = lerp(velocity.z, 0.0, FRICTION)


func _get_horizontal_speed() -> float:
	return Vector2(velocity.x, velocity.z).length()


func die() -> void:
	_mesh_container.hide()
	_hitbox.monitoring = false
	
