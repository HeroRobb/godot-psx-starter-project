class_name GameManager
extends Control

## This node is intended to be set as the main scene for your project when
## using HR PSX.
##
## This can handle scene changes and has [ScreenSpaceShaderManager] as a child,
## so it handles post processing as well. It is intended to be interacted
## with through signals from the autoload singleton [SignalMngr].There are two
## tscn files that use this script. The game_manager_with_subviwport.tscn file
## is intended for the project to be run at a resolution of 1280x720, while
## game_manager_no_subviewport.tscn is intended to be run at a resolution of
## 320x180 (in the top left of the editor project -> project settings ->
## display -> window -> viewport width/height), but either *should* work in any
## resolution you want. One of the benefits of using the subviewport version is
## that the postprocessing effects, like CRT, can be run outside the viewport
## at a higher resolution so they can look better. One of the benefits of using
## the no viewport version is that is is much chunkier and more grungy. They
## can both be used to pretty good effect. It depends on what style you are
## looking for. Keep in mind that the PSX_DITHER shader does nothing in the no
## viewport version, as it is a viewport material shader.


## This is what the max frames per second of the game will be set to. The
## default of 24 is reccomended for the retro PSX vibe, but do whatever you
## want. I'm not your dad lol
@export_range(24, 60) var fps: int = 24
## This is all of the screen space shaders which will be activated in the scene
## after the [Launcher]. It is also the screen space shaders that will be
## toggled when using [signal SignalMngr.pp_default_shaders_enabled_changed].
## It can be changed in game by using
## [signal SignalMngr.pp_default_shaders_changed].
@export var default_shaders: Array[Global.SHADERS]

## This determines if the game will pause. If this value is set to false, 
## [member paused] cannot be set to true. This should be interacted with
## through [signal SignalMngr.pause_allowed_changed].
var pause_allowed: bool = true : set = set_pause_allowed
## This determines if the game is paused. This value cannot be set to true if
## [member pause_allowed] is set to false. This should be interacted with
## through [signal SignalMngr.paused_changed].
var paused: bool = false : set = set_paused
var use_psx_dither_viewport: bool = true

var _current_scene_id: Global.LEVELS
var _previous_scene_id: Global.LEVELS
var _psx_dither_enabled: bool = true : set = _set_psx_dither_enabled

@onready var _dither_viewport_container: SubViewportContainer = $PPDitherContainer
@onready var _fade_rect: FadeRect = %FadeRect
@onready var _level_container: Node = %LevelContainer
@onready var _main_scene: Node = _level_container.get_child(0)


func _ready():
	_connect_signals()
	_debug_setup()
	
	if not _dither_viewport_container:
		use_psx_dither_viewport = false
	
	SignalManager.pp_default_shaders_changed.emit(default_shaders)
	process_mode = Node.PROCESS_MODE_ALWAYS
	Engine.max_fps = fps


func hitstop(time_scale: float, duration: float) -> void:
	Engine.time_scale = time_scale
	
	if duration <= 0:
		return
	
	await get_tree().create_timer(duration * time_scale).timeout
	Engine.time_scale = 1.0


func set_pause_allowed(new_pause_allowed: bool) -> void:
	pause_allowed = new_pause_allowed


func set_paused(new_paused: bool) -> void:
	if not pause_allowed:
		paused = false
		return
	
	paused = new_paused
	get_tree().paused = paused


func _set_psx_dither_enabled(new_psx_dither_enabled: bool) -> void:
	if not use_psx_dither_viewport:
		return
	
	_psx_dither_enabled = new_psx_dither_enabled
	
	_dither_viewport_container.material.set_shader_parameter("dithering", _psx_dither_enabled)


func set_delayed(target: Object, property_name: String, property_value, wait_seconds: float) -> void:
	get_tree().create_timer(wait_seconds, false).timeout.connect(Callable(target,"set").bind(property_name, property_value))


## This function takes care of changing scenes. It is intended to be interacted
## with through [signal SignalMngr.change_scene_needed].
func change_scene(new_scene_id: Global.LEVELS, silent: bool = false, fade_out_seconds: float = 0.5, fade_in_seconds: float = 1.0) -> void:
	if silent:
		SoundManager.stop_sfx()
		SoundManager.stop_ambience()
		SoundManager.stop_music()
	
	_fade_rect.fade_out(fade_out_seconds)
	await _fade_rect.fade_finished
	
	_previous_scene_id = _current_scene_id
	_current_scene_id = new_scene_id
	ResourceManager.add_global_data("previous_scene_id", _previous_scene_id)
	_main_scene.queue_free()
	await _main_scene.tree_exited
	
	SignalManager.time_scale_change_requested.emit(1, 0)
	ResourceManager.load_level_from_id(_current_scene_id)
	await ResourceManager.level_loaded

	var new_scene: Node = ResourceManager.get_loaded_level().instantiate()
	_level_container.add_child(new_scene)
	_level_container.move_child(new_scene, 0)
	_main_scene = new_scene
	_load_game_state_saver_data()
	if _main_scene.has_method("initialize_level"):
		_main_scene.initialize_level(_previous_scene_id)
	_fade_rect.fade_in(fade_in_seconds)


func _debug_setup() -> void:
	var category_name: String = "Level select"
	var level_keys: Array = Global.LEVELS.keys()
	for level_part in (level_keys.size() / DebugMenu.DEBUG_LIMIT) + 1:
		var min_index = level_part * DebugMenu.DEBUG_LIMIT
		var max_index = min((level_part + 1) * DebugMenu.DEBUG_LIMIT, level_keys.size())
		
		if min_index >= level_keys.size():
			break
		
		var numbered_category_name: String = "%s %d" % [category_name, level_part]
		DebugMenu.add_category(numbered_category_name)
		for i in range(min_index, max_index):
			var formatted_name: String = level_keys[i].to_lower().capitalize()
			DebugMenu.add_option(numbered_category_name, formatted_name, change_scene, [ Global.LEVELS[level_keys[i] ], true])


func _load_game_state_saver_data() -> void:
	for n in get_tree().get_nodes_in_group(Global.GAME_STATE_SAVER_GROUP):
		var node: GameStateSaver = n
		var data_to_load
		
		if node.debug:
			breakpoint
		if node.global:
			data_to_load = ResourceManager.get_global_data(node.parent.name)
		else:
			data_to_load = ResourceManager.get_scene_data(node.get_path())
		
		if data_to_load is Dictionary:
			node.load_data(data_to_load)


func _connect_signals() -> void:
	SignalManager.change_scene_requested.connect(change_scene)
	SignalManager.pause_allowed_changed.connect(set_pause_allowed)
	SignalManager.paused_changed.connect(set_paused)
	SignalManager.set_delayed.connect(set_delayed)
	SignalManager.pp_enabled_changed.connect(_on_pp_enabled_changed)
	SignalManager.pp_default_shaders_enabled_changed.connect(_on_pp_default_shaders_enabled_changed)
	SignalManager.time_scale_change_requested.connect(hitstop)


func _on_pp_enabled_changed(shader: Global.SHADERS, enabled: bool) -> void:
	if shader == Global.SHADERS.PSX_DITHER:
		_set_psx_dither_enabled(enabled)


func _on_pp_default_shaders_enabled_changed(enabled: bool) -> void:
	if default_shaders.has(Global.SHADERS.PSX_DITHER):
		_set_psx_dither_enabled(enabled)
