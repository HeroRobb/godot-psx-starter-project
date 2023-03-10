extends Node3D


@onready var _animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	await get_tree().create_timer(randf_range(0.2, 0.5)).timeout
	move_to_random_location()
	rotate_to_random_direction()
	play_random_animation()


func move_to_random_location(range: float = 8.0) -> void:
	randomize()
	var rand_x: float = randf_range(0 - range, range)
	var rand_y: float = randf_range(0 - range, range)
	var random_vector: Vector2 = Vector2(rand_x, rand_y)
	
	global_transform.origin = Vector3(rand_x, 0, rand_y)


func rotate_to_random_direction() -> void:
	randomize()
	var rand_rotation: float = randf_range(0, 2 * PI)
	rotate_y(rand_rotation)


func play_random_animation() -> void:
	randomize()
	var random_number = randi_range(0, 2)
	
	match random_number:
		0:
			_animation_player.play("Jump")
		1:
			_animation_player.play("Dance")
		2:
			_animation_player.play("Bite_Front")
