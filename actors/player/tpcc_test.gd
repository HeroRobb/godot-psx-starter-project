extends CharacterBody3D


@onready var head = $HEAD

@export var speed          : float = 10
@export var gravity        : float = 40
@export var ground_accel   : float = 8
@export var air_accel      : float = 2
@export var jump_force     : float = 20
@export var friction       : float = 0.25

var dir : Vector3
var vel : Vector3


func _process(delta):
	dir.x = Input.get_action_strength("LEFT") - Input.get_action_strength("RIGHT")
	dir.z = Input.get_action_strength("FORWARD") - Input.get_action_strength("BACKWARD")
	dir = dir.rotated(Vector3.UP, head.rotation.y).normalized()


func _physics_process(delta):
	grav(delta)
	jump(delta)
	mov(delta)


func grav(delta):
	vel.y -= gravity * delta
	set_velocity(vel)
	set_up_direction(Vector3.UP)
	move_and_slide()
	vel = velocity


func mov(delta):
	if is_on_floor():
		if dir.x != 0 or dir.z != 0:
			vel.x = lerp(vel.x, dir.x * speed, ground_accel * delta)
			vel.z = lerp(vel.z, dir.z * speed, ground_accel * delta)
		else:
			vel.x = lerp(vel.x, 0, friction)
			vel.z = lerp(vel.z, 0, friction)
	else:
		if dir.x != 0 or dir.z != 0:
			vel.x = lerp(vel.x, dir.x * speed, air_accel * delta)
			vel.z = lerp(vel.z, dir.z * speed, air_accel * delta)


func jump(delta):
	if is_on_floor():
		if Input.is_action_just_pressed("JUMP"):
			vel.y = jump_force
