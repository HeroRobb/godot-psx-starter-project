extends Node
class_name GameStateSaver


# warning-ignore-all:unused_signal
signal loading_data(data)
signal saving_data(data)

const GAME_STATE_KEY_NODE_PATH = "game_state_saver_node_path"

@export var save_properties: Array[String]
@export var dynamic_instance: bool
@export var global: bool
@export var debug: bool

@onready var parent: Node = get_parent()


func _ready() -> void:
	add_to_group(Global.GAME_STATE_SAVER_GROUP)


func _exit_tree() -> void:
	if dynamic_instance:
		return
	
	var key: String
	if debug:
		breakpoint
	if global:
		key = parent.name
	else:
		key = get_path()
	
	SignalManager.state_saver_freed.emit(global, key, get_save_data())


func get_parent_path() -> NodePath:
	return parent.get_path()


func get_save_data() -> Dictionary:
	var node_data: Dictionary = {}
	
	node_data[GAME_STATE_KEY_NODE_PATH] = parent.get_path()
	
	for prop_name in save_properties:
		node_data[prop_name] = parent.get(prop_name)
	
	return node_data


func load_data(loaded_data: Dictionary) -> void:
	if loaded_data.freed:
		parent.queue_free()
		return
	for prop_name in loaded_data:
		parent.set(prop_name, loaded_data[prop_name])
