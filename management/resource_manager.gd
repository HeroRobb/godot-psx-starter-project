class_name ResourceMngr
extends Node

## Handles all of your files of nodes and resources to be used in your game
##
## This class can be used in two ways. You can either use an editor based
## approach or a code based one.
## To use either approach, This requires you to have edited 
## res://management/global.gd and added to the appropriate enums for your
## particular game.
## To use the editor based approach, you should open
## res://management/resource_manager.tscn in the editor, set
## use_editor_resources to true, and change the appropriate data array.
## To use the code based approach, you should extend this class in a script
## (eg, res://management/resource_manager_your_game.gd) and override the _ready
## function to call the various add functions. There is a template for this so
## you know which functions are available. Make sure to remove
## ResourceManager.tscn from autoloads and replace it with your
## resource_manager_your_game.gd script. DO NOT FORGET THAT IF YOU CHANGE THE
## FILE NAMES OR THEIR PATHS IN ANY WAY, YOU HAVE TO UPDATE THE RESOURCE IN
## NODE'S DATA ARRAY IN THE EDITOR.
## I had to use a shortened name because this class cannot have the same name
## as the autoload name.


signal level_loaded()

## Set this to true to use the editor resource arrays below.
@export var use_editor_resources: bool = false
@export var music_data: Array[MusicData]
@export var ambience_data: Array[AmbienceData]
@export var sfx_data: Array[SFXData]
@export var level_data: Array[LevelData]


const _FULLSCREEN_WINDOW_SIZE = Vector2(1280, 720)
const _MED_WINDOW_SIZE = Vector2(1280, 720)
const _SMALL_WINDOW_SIZE = Vector2(640, 360)
const _OK_LOADING_STATUSES = [ResourceLoader.THREAD_LOAD_IN_PROGRESS, ResourceLoader.THREAD_LOAD_LOADED]

var version_number = 0.1

var loading_level: bool = false : set = set_loading_level

var _starting_scene: Global.LEVELS
var _data: GameData = preload("res://management/game_data.gd").new()
var _actors: Dictionary
var _level_paths: Dictionary
var _particles: Dictionary
var _shaders: Dictionary
var _loading_level_path: String


func _ready() -> void:
	_connect_signals()
	_initialize_data()
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(_delta: float) -> void:
	if not loading_level:
		set_loading_level(false)
		return
	
	var status: ResourceLoader.ThreadLoadStatus = ResourceLoader.load_threaded_get_status(_loading_level_path)
	
	assert(_OK_LOADING_STATUSES.has(status), "There was an error while loading %s." % _loading_level_path)
	
	if status == ResourceLoader.THREAD_LOAD_LOADED:
		level_loaded.emit()
		set_loading_level(false)


func get_actor_packed_scene(actor_id: int) -> PackedScene:
	if not _actors.has(actor_id):
		return null
	
	return _actors[actor_id]


func load_level_from_id(level_id: int):
	if not _level_paths.has(level_id):
		return null
	
	_loading_level_path = _level_paths[level_id]
	
	ResourceLoader.load_threaded_request(_loading_level_path, "PackedScene")
	set_loading_level(true)


func get_loaded_level() -> PackedScene:
	var level = ResourceLoader.load_threaded_get(_loading_level_path)
	_loading_level_path = ""
	return level


func get_level_packed_scene(level_id: int) -> PackedScene:
	var level_packed_scene = load(_level_paths[level_id])
	return level_packed_scene


func get_particle_packed_scene(particle_id: int) -> PackedScene:
	if not _particles.has(particle_id):
		return null
	
	return _particles[particle_id]


func get_shader_resource(shader_id: int) -> Resource:
	if not _shaders.has(shader_id):
		return null
	
	return _shaders[shader_id]


func set_loading_level(new_loading_level: bool) -> void:
	loading_level = new_loading_level
	
	set_process(loading_level)


func set_master_volume(new_volume: float) -> void:
	add_global_data("master_volume", new_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), new_volume)


func set_sfx_volume(new_volume: float) -> void:
	add_global_data("sfx_volume", new_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), new_volume)


func set_music_volume(new_volume: float) -> void:
	add_global_data("music_volume", new_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), new_volume)


func set_ambience_volume(new_volume: float) -> void:
	add_global_data("ambience_volume", new_volume)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Ambience"), new_volume)


func set_window_mode(new_window_mode: int) -> void:
	add_global_data("window_mode", new_window_mode)
	
	match new_window_mode:
		Global.WINDOW_MODES.FULLSCREEN:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			DisplayServer.window_set_size(_FULLSCREEN_WINDOW_SIZE)
		Global.WINDOW_MODES.BORDERLESS:
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(DisplayServer.screen_get_size())
#			OS.center_window()
		Global.WINDOW_MODES.WINDOWED_MED:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(_MED_WINDOW_SIZE)
#			OS.center_window()
		Global.WINDOW_MODES.WINDOWED_SMALL:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
			DisplayServer.window_set_size(_SMALL_WINDOW_SIZE)
#			OS.center_window()


func add_global_data(data_id: String, data_value) -> void:
	_data.add_global_data(data_id, data_value)


func get_global_data(data_id: String):
	return _data.get_global_data(data_id)


func add_scene_data(data_id: String, data_value) -> void:
	_data.add_scene_data(data_id, data_value)


func get_scene_data(data_id: String):
	return _data.get_scene_data(data_id)


func add_actor(actor_id: int, path_to_scene: String) -> void:
	_actors[actor_id] = load(path_to_scene)


func add_level(level_id: Global.LEVELS, path_to_scene: String) -> void:
	_level_paths[level_id] = path_to_scene


func add_particle(particle_id: int, path_to_scene: String) -> void:
	_particles[particle_id] = load(path_to_scene)


func add_shader(shader_id: int, path_to_resource: String) -> void:
	_shaders[shader_id] = load(path_to_resource)


func add_music(music_id: Global.MUSIC, path_to_resource: String) -> void:
	SignalManager.music_load_needed.emit(music_id, path_to_resource)


func add_ambience(ambience_id: Global.AMBIENCES, path_to_resource: String) -> void:
	SignalManager.ambience_load_needed.emit(ambience_id, path_to_resource)


func add_sfx(sfx_id: Global.SFX, path_to_resource: String) -> void:
	SignalManager.sfx_load_needed.emit(sfx_id, path_to_resource)


func _initialize_data() -> void:
	add_global_data("debug", OS.is_debug_build())
	add_global_data("master_volume", 1.0)
	add_global_data("sfx_volume", 1.0)
	add_global_data("music_volume", 1.0)
	add_global_data("ambience_volume", 1.0)
	add_global_data("window_mode", Global.WINDOW_MODES.FULLSCREEN)
	add_global_data("version", version_number)
	
	if not use_editor_resources:
		return
	
	for data in level_data:
		var this_level_data: LevelData = data
		add_level(this_level_data.level_id, this_level_data.data_path)
	
	for data in music_data:
		var this_music_data: MusicData = data
		add_music(this_music_data.music_id, this_music_data.data_path)
	
	for data in ambience_data:
		var this_ambience_data: AmbienceData = data
		add_ambience(this_ambience_data.ambience_id, this_ambience_data.data_path)
	
	for data in sfx_data:
		var this_sfx_data: SFXData = data
		add_sfx(this_sfx_data.sfx_id, this_sfx_data.data_path)


func _connect_signals() -> void:
	SignalManager.state_saver_freed.connect(_on_state_saver_freed)
	SignalManager.set_window_mode.connect(set_window_mode)
	
#	SignalManager.pp_default_shaders_changed
#	SignalManager.pp_default_shaders_enabled_changed
#	SignalManager.pp_enabled_changed


func _on_state_saver_freed(global: bool, key: String, save_data: Dictionary) -> void:
	if global:
		add_global_data(key, save_data)
		return
	
	add_scene_data(key, save_data)
