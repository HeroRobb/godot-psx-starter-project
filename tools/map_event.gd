extends Node2D


const margin: float = 20

var children: Array

@onready var _sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_apply_random_texture()


func add_child_event(child) -> void:
	if not children.has(child):
		children.append(child)
		queue_redraw()


func _draw() -> void:
#	draw_circle(Vector2.ZERO, 4, Color.WHITE_SMOKE)
	
	for child in children:
		var line: Vector2 = child.position - position
		var normal: Vector2 = line.normalized()
		line -= margin * normal
		var color = Color.DIM_GRAY
		draw_line(normal * margin, line, color, 2, true)


func _apply_random_texture() -> void:
	var texture
	randomize()
	
	match randi_range(0, 5):
		0: texture = load("res://materials/textures/Castle.png")
		1: texture = load("res://materials/textures/Inferno.png")
		2: texture = load("res://materials/textures/Necropolis.png")
		3: texture = load("res://materials/textures/Rampart.png")
		4: texture = load("res://materials/textures/Stronghold.png")
		5: texture = load("res://materials/textures/Tower.png")
	_sprite.texture = texture
