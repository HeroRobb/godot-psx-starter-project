class_name NavigationComponent2D
extends Node2D


signal target_node_lost()
signal target_location_reached()

@export var _movement_component: MovementComponent2D

var disabled: bool = false
var target_node: Node2D : set = set_target_node
var target_location: Vector2 : set = set_target_location

var _next_location: Vector2

@onready var _navigation_agent: NavigationAgent2D = $NavigationAgent2D


func _ready() -> void:
	assert(_movement_component, "Navigation component has no movement component set.")


func _physics_process(delta: float) -> void:
	if disabled:
		return
	
	if target_location:
		_next_location = get_path_to_target_location()
		_movement_component.move_to(_next_location, delta)
	
	if target_node:
		_update_target_node_location()
	
	if _navigation_agent.is_target_reached():
		target_location_reached.emit()


func set_target_location(new_location: Vector2) -> void:
	target_location = new_location
	
	_navigation_agent.target_position = target_location


func set_target_node(new_target_node: Node2D) -> void:
	target_node = new_target_node
	
	if target_node:
		_update_target_node_location()


func get_path_to_target_location() -> Vector2:
	_navigation_agent.set_velocity(_movement_component.velocity)
	return _navigation_agent.get_next_path_position()


func disable() -> void:
	disabled = true


func enable() -> void:
	disabled = false


func _update_target_node_location() -> void:
	set_target_location(target_node.global_position)
