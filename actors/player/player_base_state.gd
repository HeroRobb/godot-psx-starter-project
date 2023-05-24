@tool
extends State


# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	pass

func _after_enter(_args) -> void:
	pass

func _on_update(delta) -> void:
	_calculate_gravity(delta)
#	_calculate_movement(delta)

func _after_update(_delta) -> void:
	pass

func _before_exit(_args) -> void:
	pass

func _on_exit(_args) -> void:
	pass

func _on_timeout(_name) -> void:
	pass


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		change_state("Attack")
	elif event.is_action_pressed("rotate_camera_right"):
		target.rotate_camera_right()
	elif event.is_action_pressed("rotate_camera_left"):
		target.rotate_camera_left()


func _calculate_gravity(delta: float) -> void:
	var current_gravity
	current_gravity = target.GROUND_GRAVITY if target.is_on_floor() else target.AIR_GRAVITY
	target.velocity.y += delta * current_gravity


#func _calculate_movement(delta: float) -> void:
#	if direction.x != 0 or direction.y != 0:
#		velocity.x = lerp(velocity.x, direction.x * max_speed, GROUND_ACCELERATION * delta)
#		velocity.z = lerp(velocity.z, direction.y * max_speed, GROUND_ACCELERATION * delta)
#		return
#
#	velocity.x = lerp(velocity.x, 0, FRICTION)
#	velocity.z = lerp(velocity.z, 0, FRICTION)
