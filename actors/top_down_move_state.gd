@tool
extends AnimationState


func _on_enter(_args) -> void:
	target.velocity = Vector3.ZERO

func _after_enter() -> void:
	pass

func _on_update(_delta) -> void:
	pass

func _after_update(delta) -> void:
	if target.get_horizontal_speed() > 0.1:
		target.mesh_container.rotation.y = lerp_angle(target.mesh_container.rotation.y, atan2(-target.velocity.x, -target.velocity.z), delta * target.ANGULAR_ACCELERATION)
#		if not is_playing("Walk"): play("Walk")
	
	target.set_velocity(target.velocity)
	target.set_up_direction(Vector3.UP)
	target.move_and_slide()
	target.velocity = target.velocity
	target.navigation_agent.set_velocity(target.velocity)

func _before_exit() -> void:
	pass

func _on_exit(_args) -> void:
	pass

func _on_timeout(_name) -> void:
	pass
