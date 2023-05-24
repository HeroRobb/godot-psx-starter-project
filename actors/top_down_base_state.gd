extends State


# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	pass

func _after_enter() -> void:
	pass

func _on_update(delta) -> void:
	var current_gravity
	current_gravity = target.GROUND_GRAVITY if target.is_on_floor() else target.AIR_GRAVITY
	target.velocity.y += delta * current_gravity

func _after_update(_delta) -> void:
	pass

func _before_exit() -> void:
	pass

func _on_exit(_args) -> void:
	pass

func _on_timeout(_name) -> void:
	pass
