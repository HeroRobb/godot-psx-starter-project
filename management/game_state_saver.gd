class_name GameStateSaver
extends Node

## This node saves any data you choose from it's parent that needs to persist
## between scenes.
##
## This is intended to be used in conjunction with the autoload singleton
## [ResourceMngr] in HR PSX. Add it as a child to any node and edit
## [member save_properties] in the editor. Each entry in save_properties should
## be a member of this node's parent. When this node's parent is freed, all the
## members in save_properties will be saved to [GameData] through [ResourceMngr]
## and when this node's parent enters into the scene tree again, all of it's
## members data contained in save_properties will be restored. This script is
## heavily based on a similar node by Jason Lothamer.
##
## @tutorial(Jason's tutorial): https://www.youtube.com/watch?v=_gBpk5nKyXU


const _GAME_STATE_KEY_NODE_PATH = "game_state_saver_node_path"

## An array of properties of this node's parent that will be saved when the
## parent is freed and restored when it is loaded again.
@export var save_properties: Array[String]
@export var dynamic_instance: bool
## If this value is set to true, the parent's data will be saved as global data
## through [ResourceMngr] instead of scene data.
@export var global: bool
## If this value is set to true, there will be a breakpoint each time this node
## loads or saves data from its parent.
@export var debug: bool

@onready var _parent: Node = get_parent()


func _ready() -> void:
	add_to_group(Global.GAME_STATE_SAVER_GROUP)


func _exit_tree() -> void:
	if dynamic_instance:
		return
	
	var key: String
	if debug:
		breakpoint
	if global:
		key = _parent.name
	else:
		key = get_path()
	
	SignalManager.state_saver_freed.emit(global, key, get_save_data())


func get_parent_path() -> NodePath:
	return _parent.get_path()


func get_save_data() -> Dictionary:
	var node_data: Dictionary = {}
	
	node_data[_GAME_STATE_KEY_NODE_PATH] = _parent.get_path()
	
	for prop_name in save_properties:
		node_data[prop_name] = _parent.get(prop_name)
	
	return node_data


func load_data(loaded_data: Dictionary) -> void:
	if loaded_data.freed:
		_parent.queue_free()
		return
	for prop_name in loaded_data:
		_parent.set(prop_name, loaded_data[prop_name])
