class_name AreaContainer
extends Node3D

## A container for areas in levels.
##
## Put Area3D's as children of SafetyNetContainer and they will call
## teleport_player_to_safety() in PlayerContainer. I use this for places a
## player could fall into infinity.


@onready var _safety_net_container := $SafetyNetContainer

var _safety_nets: Array


func _ready() -> void:
	var safety_net_children = _safety_net_container.get_children()
	if not safety_net_children.is_empty():
		
		for n in safety_net_children.size():
			_safety_nets.append( safety_net_children[n] )


## This is called by [Level] when it is connecting signals from the areas in
## the SafetyNetContainer.
func get_safety_nets() -> Array:
	return _safety_nets
