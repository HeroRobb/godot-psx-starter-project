extends Marker3D


@export_range(1.0, 4.0, 0.5) var rotation_speed: float = 2.0


func _process(delta: float) -> void:
	rotate_y(rotation_speed * delta)
