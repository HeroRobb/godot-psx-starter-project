class_name PatrolPath
extends Node3D


enum PATROL_TYPES {
	LOOPED,
	BACK_AND_FORTH,
}


@export var patrol_type: PATROL_TYPES = PATROL_TYPES.BACK_AND_FORTH

var _patrol_points: Array
var _patrolling_agents: Dictionary
var _next_available_agent_id: int = 0


func _ready() -> void:
	_initialize_patrol_points()


func subscribe_to_patrol(new_patroller: Node) -> int:
	for helper_id in _patrolling_agents:
		var helper: PatrolHelper = _patrolling_agents[helper_id]
		if helper.agent == new_patroller:
			return helper.current_patrol_position
	
	var new_agent_id = _next_available_agent_id
	var patrol_helper = PatrolHelper.new(new_patroller)
	_patrolling_agents[new_agent_id] = patrol_helper
	_next_available_agent_id += 1
	return new_agent_id


func get_current_patrol_point(agent_id: int) -> Vector3:
	var patrol_helper: PatrolHelper = _patrolling_agents[agent_id]
	var patrol_position: Marker3D = _patrol_points[patrol_helper.current_patrol_position_index]
	return patrol_position.global_transform.origin


func get_next_patrol_point(agent_id: int) -> Vector3:
	_advance_patrol_point(agent_id)
	return get_current_patrol_point(agent_id)


func restart_patrol(agent_id: int) -> void:
	var patrol_helper: PatrolHelper = _patrolling_agents.get(agent_id)
	
	if not patrol_helper:
		return
	
	patrol_helper.current_patrol_position_index = 0


func unsubscribe_from_patrol(agent_id: int) -> void:
	if _patrolling_agents.has(agent_id):
		_patrolling_agents.erase(agent_id)


func _advance_patrol_point(agent_id: int) -> void:
	var patrol_helper = _patrolling_agents.get(agent_id)
	if not patrol_helper:
		return
	
	if patrol_helper.patrolling_backwards:
		patrol_helper.current_patrol_position_index -= 1
	else:
		patrol_helper.current_patrol_position_index += 1
	
	if patrol_helper.current_patrol_position_index >= _patrol_points.size():
		if patrol_type == PATROL_TYPES.LOOPED:
			patrol_helper.current_patrol_position_index = 0
		elif patrol_type == PATROL_TYPES.BACK_AND_FORTH:
			patrol_helper.patrolling_backwards = true
			patrol_helper.current_patrol_position_index = _patrol_points.size() - 2
			
	if patrol_helper.current_patrol_position_index < 0:
		if patrol_type == PATROL_TYPES.LOOPED:
			patrol_helper.current_patrol_position_index = _patrol_points.size() - 1
		elif patrol_type == PATROL_TYPES.BACK_AND_FORTH:
			patrol_helper.patrolling_backwards = false
			patrol_helper.current_patrol_position_index = 1


func _initialize_patrol_points() -> void:
	for node in get_children():
		if node is Marker3D:
			_patrol_points.append(node)


class PatrolHelper:
	
	var agent: Node
	var agent_id: int
	var current_patrol_position_index: int
	var patrolling_backwards: bool
	
	func _init(init_agent: Node,init_patrol_position: int = 0,init_patrolling_backwards: bool = false):
		agent = init_agent
		current_patrol_position_index = init_patrol_position
		patrolling_backwards = init_patrolling_backwards
