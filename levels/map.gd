extends Node2D


const map_scale = 60.0

@export var plane_length: int = 12
@export var node_count: int = plane_length * plane_length / 5
@export var path_count: int = 12

var _camera_speed: float = 250
var _events: Dictionary
var _event_scene: PackedScene = preload("res://tools/map_event.tscn")

@onready var _map_events: Node2D = $MapEvents
@onready var _camera: Camera2D = $Camera2D


func _ready() -> void:
	_generate_map()


func _process(delta: float) -> void:
	if Input.is_action_pressed("move_forward"):
		_camera.position.y -= _camera_speed * delta
	if Input.is_action_pressed("move_backward"):
		_camera.position.y += _camera_speed * delta
	if Input.is_action_pressed("move_right"):
		_camera.position.x += _camera_speed * delta
	if Input.is_action_pressed("move_left"):
		_camera.position.x -= _camera_speed * delta


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		_generate_map()


func _generate_map() -> void:
	_remove_map()
	
	var map_generator: MapGenerator = MapGenerator.new()
	var map_data: MapData = map_generator.generate(plane_length, node_count, path_count)
	
	_camera.position = map_data.nodes[0] * map_scale + Vector2(500, 0)
	
	for k in map_data.nodes.keys():
		var point = map_data.nodes[k]
		var event = _event_scene.instantiate()
		event.position = point * map_scale + Vector2(200, 0)
		_map_events.add_child(event)
		_events[k] = event
	
	for path in map_data.paths:
		for i in range(path.size() - 1):
			var index_1 = path[i]
			var index_2 = path[i + 1]
			
			_events[index_1].add_child_event(_events[index_2])


func _remove_map() -> void:
	for event in _map_events.get_children():
		event.queue_free()
