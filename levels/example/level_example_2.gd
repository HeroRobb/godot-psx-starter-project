# meta_description: Contains all of the functions you should override
# meta_default: true


extends Level


const MINIMUM_TRANSITION_SECONDS = 3.0
const MAXIMUM_TRANSITION_SECONDS = 6.0

var _new_default_shaders: Array[int] = [
	Global.SHADERS.PSX_DITHER,
	Global.SHADERS.CRT,
	Global.SHADERS.SHARPNESS
]
var camera_index: int = 0

@onready var _cameras: Array = [
	$PlayerContainer/Camera3D,
	$PlayerContainer/Camera3D2,
	$PlayerContainer/Camera3D3,
	$PlayerContainer/Camera3D4,
]


func _ready() -> void:
	super()
	SignalManager.pp_default_shaders_changed.emit(_new_default_shaders)
	SignalManager.pp_default_shaders_enabled_changed.emit(true)
	SignalManager.camera_transition_finished.connect(_on_camera_transition_finished)
	SignalManager.camera_cut_requested.emit(_cameras[camera_index])
	_transition_to_next_camera()


## This is the logic that will be called with the previous scenes id from
## [member Glbl.LEVELS] so you can have run logic based on the previous
## level/scene. Keep in mind that this runs after [method ready].
func initialize_level(previous_scene_id: Global.LEVELS) -> void:
	_player_container.move_player_to_spawn_position(previous_scene_id)


func _transition_to_next_camera() -> void:
	camera_index += 1
	
	if camera_index >= _cameras.size():
		camera_index = 0
	
	var transition_seconds: float = randf_range(MINIMUM_TRANSITION_SECONDS, MAXIMUM_TRANSITION_SECONDS)
	
	SignalManager.camera_transition_requested.emit(_cameras[camera_index], transition_seconds)


func _on_camera_transition_finished() -> void:
	_transition_to_next_camera()
