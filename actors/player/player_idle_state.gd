@tool
extends State


# FUNCTIONS AVAILABLE TO INHERIT

func _on_enter(_args) -> void:
	play("Idle")

func _after_enter(_args) -> void:
	pass

func _on_update(_delta) -> void:
	pass

func _after_update(_delta) -> void:
	_check_transition()

func _before_exit(_args) -> void:
	pass

func _on_exit(_args) -> void:
	pass

func _on_timeout(_name) -> void:
	pass


func _check_transition() -> void:
	if not target.direction == Vector3.ZERO:
		change_state("Walk")
