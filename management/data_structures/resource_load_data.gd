class_name ResourceLoadManager
extends Node


const _OK_LOADING_STATUSES = [ResourceLoader.THREAD_LOAD_IN_PROGRESS, ResourceLoader.THREAD_LOAD_LOADED]

var _loading_resource: bool = false
var _loading_resource_paths: Array[String]
var _loaded_resource_paths: Array[String]


func _process(_delta: float) -> void:
	for path in _loading_resource_paths:
		var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(path)
		assert(_OK_LOADING_STATUSES.has(status), "There was an error while loading %s." % path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			resource_loaded.emit()
			_move_resource_to_loaded_array()

	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_loading_level_path)

	assert(_OK_LOADING_STATUSES.has(status), "There was an error while loading %s." % _loading_level_path)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		level_loaded.emit()
		set_loading_resource(false)


func load_resource(path_to_resource: String) -> void:
	_loading_resource_paths.append(path_to_resource)
	ResourceLoader.load_threaded_request(path_to_resource)
	set_loading_resource(true)


func set_loading_resource(new_loading_resource: bool) -> void:
	_loading_resource = new_loading_resource
	set_process(_loading_resource)
