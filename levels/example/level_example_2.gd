# meta_description: Contains all of the functions you should override
# meta_default: true


extends Level3D


const NEXT_SCENE = Global.LEVELS.TEST
const MINIMUM_TRANSITION_SECONDS = 3.0
const MAXIMUM_TRANSITION_SECONDS = 6.0

var _level_default_shaders: Array[int] = [
	Global.SHADERS.SHARPNESS
]
var camera_index: int = 0

@onready var _ui_level_controls: UILevelControls = $UILevelControls
@onready var _cameras: Array = [
	$PlayerContainer/Camera3D,
	$PlayerContainer/Camera3D5,
	$PlayerContainer/Camera3D2,
	$PlayerContainer/Camera3D3,
	$PlayerContainer/Camera3D4,
]


func _ready() -> void:
	super()
	_activate_shaders()
	SignalManager.camera_transition_finished.connect(_on_camera_transition_finished)
	SignalManager.camera_cut_requested.emit(_cameras[camera_index])
	_transition_to_next_camera()


func _input(event: InputEvent) -> void:
	_ui_level_controls.handle_input(event)


func favorite_scene() -> void:
	ResourceManager.add_global_data("favorite_scene", level_id)


func change_to_next_scene() -> void:
	SignalManager.change_scene_requested.emit(NEXT_SCENE)


func _transition_to_next_camera() -> void:
	camera_index += 1
	
	if camera_index >= _cameras.size():
		camera_index = 0
	
	var transition_seconds: float = randf_range(MINIMUM_TRANSITION_SECONDS, MAXIMUM_TRANSITION_SECONDS)
	
	SignalManager.camera_transition_requested.emit(_cameras[camera_index], transition_seconds)


func _activate_shaders() -> void:
	for shader in _level_default_shaders:
		SignalManager.pp_enabled_changed.emit(shader, true)


func _connect_signals() -> void:
	super()
	_ui_level_controls.next_scene_requested.connect(change_to_next_scene)
	_ui_level_controls.favorite_scene_requested.connect(favorite_scene)
	SignalManager.game_save_load_finished.connect(_on_game_save_loaded)


func _on_camera_transition_finished() -> void:
	_transition_to_next_camera()


func _on_game_save_loaded() -> void:
	var favorite_scene_id: Global.LEVELS = ResourceManager.get_global_data("favorite_scene")
	if not favorite_scene_id:
		favorite_scene_id = Global.LEVELS.TEST
	
	SignalManager.change_scene_requested.emit(favorite_scene_id)
