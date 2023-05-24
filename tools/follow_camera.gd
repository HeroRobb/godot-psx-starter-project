extends Camera2D


@export var linear_accleration: float = 4.0
@export var angular_acceleration: float = 4.0
@export var target_path: NodePath

var target: Node2D


func _ready():
	if target_path == null:
		return
	
	target = get_node(target_path)


func _process(delta):
	if not target:
		return
	
	rotation = lerp_angle(rotation, target.rotation, delta * angular_acceleration)
	position = lerp(global_position, target.global_position, delta * linear_accleration)
