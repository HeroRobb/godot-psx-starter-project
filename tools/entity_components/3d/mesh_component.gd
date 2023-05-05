class_name MeshComponent
extends Node3D


signal flashing_finished()

const FLASH_LENGTH: float = 0.05

@export_range(2.0, 10.0, 0.25) var angular_acceleration: float = 4.0

@onready var _flash_timer: Timer = $FlashTimer


func turn(velocity: Vector3, delta: float) -> void:
	if _get_horizontal_speed(velocity) > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * angular_acceleration)


func flash(flash_time: float, bright_flash: bool = true) -> void:
	while flash_time > FLASH_LENGTH * 2:
		visible = not visible
		_flash_timer.start(FLASH_LENGTH)
		flash_time -= FLASH_LENGTH
		await(_flash_timer.timeout)
	
	_flash_timer.start(FLASH_LENGTH * 2)
	visible = false
	await(_flash_timer.timeout)
	visible = true
	flashing_finished.emit()


func rotate_degrees(rotation_degree_vector: Vector3, delta: float) -> void:
	rotation += rotation_degree_vector * delta


func _get_horizontal_speed(velocity: Vector3) -> float:
	return Vector2(velocity.x, velocity.z).length()
