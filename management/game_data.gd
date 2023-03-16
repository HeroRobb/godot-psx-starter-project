class_name GameData
extends Resource

## A Resource containing all of the data that needs to persist between scene
## changes.
##
## This resource is primarily used in HR PSX in conjunction with the
## [GameStateSaver] node. [ResourceMngr] should handle everything this needs
## to do so I wouldn't mess with it too much unless you need it to do something
## beyond its normal functionality.


@export var _meta_data: Dictionary
@export var _global_data: Dictionary
@export var _scene_data: Dictionary


func get_meta_data(name: String):
	if _meta_data.has(name):
		return _meta_data[name]
	return null


func get_global_data(name: String):
	if _global_data.has(name):
		return _global_data[name]
	return null


func get_scene_data(name: String):
	if _scene_data.has(name):
		return _scene_data[name]
	return null


func add_meta_data(name: String, new_meta_data) -> void:
	_meta_data[name] = new_meta_data


func add_global_data(name: String, new_global_data) -> void:
	_global_data[name] = new_global_data


func add_scene_data(name: String, new_scene_data) -> void:
	_scene_data[name] = new_scene_data
