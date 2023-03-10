class_name AreaContainer
extends Node3D


@onready var _safety_net_container := $SafetyNetContainer

var _safety_nets: Array


func _ready() -> void:
	var safety_net_children = _safety_net_container.get_children()
	if not safety_net_children.is_empty():
		
		for n in safety_net_children.size():
			_safety_nets.append( safety_net_children[n] )


func get_safety_nets() -> Array:
	return _safety_nets
