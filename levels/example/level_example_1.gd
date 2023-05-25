extends Level3D


enum CAMERA_IDS {
	SPINNING,
	SIDE,
	UP,
	TOP,
}

const CAMERA_TRANSITION_DURATION_SECONDS = 2.0
const NEXT_SCENE = Global.LEVELS.TEST2

var active_camera_id: CAMERA_IDS = CAMERA_IDS.SPINNING
var finished: bool = false
var fullscreen: bool = true

var _auto_cycle_cameras: bool = false
var _transitioning_camera: bool = false

@onready var _camera_pivot: Node3D = %SpinningCameraPivot
@onready var _camera_spinning: Camera3D = _camera_pivot.get_child(0)
@onready var _camera_side: Camera3D = %CameraSide
@onready var _camera_up: Camera3D = %CameraUp
@onready var _camera_top: Camera3D = %CameraTop
@onready var _cameras: Dictionary = {
	CAMERA_IDS.SPINNING: _camera_spinning,
	CAMERA_IDS.SIDE: _camera_side,
	CAMERA_IDS.UP: _camera_up,
	CAMERA_IDS.TOP: _camera_top,
}
@onready var _ui_level_controls: UILevelControls = $UILevelControls


func _ready() -> void:
	super()
	SignalManager.camera_cut_requested.emit(_camera_spinning)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_home"):
		toggle_fullscreen()
	
	if _transitioning_camera or finished:
		return
	
	_ui_level_controls.handle_input(event)


func _process(delta: float) -> void:
	_camera_pivot.rotate_y(delta)


func change_to_camera(camera_id: CAMERA_IDS) -> void:
	_transitioning_camera = true
	if _cameras[active_camera_id] == _camera_spinning:
		set_process(false)
	
	active_camera_id = camera_id
	var to_camera = _cameras[active_camera_id]
	
	SignalManager.camera_transition_requested.emit(to_camera, CAMERA_TRANSITION_DURATION_SECONDS)
	await SignalManager.camera_transition_finished
	
	_transitioning_camera = false
	set_process(to_camera == _camera_spinning)


func cycle_cameras() -> void:
	var next_camera_id: CAMERA_IDS = wrapi( active_camera_id + 1, 0, _cameras.size() )
	change_to_camera(next_camera_id)


func toggle_auto_cycle_cameras() -> void:
	_auto_cycle_cameras = not _auto_cycle_cameras
	
	if _auto_cycle_cameras:
		cycle_cameras()


func favorite_scene() -> void:
	ResourceManager.add_global_data("favorite_scene", level_id)


func change_to_next_scene() -> void:
	SignalManager.change_scene_requested.emit(NEXT_SCENE)


func toggle_fullscreen() -> void:
	fullscreen = not fullscreen
	if fullscreen:
		SignalManager.set_window_mode.emit(Global.WINDOW_MODES.FULLSCREEN)
	else:
		SignalManager.set_window_mode.emit(Global.WINDOW_MODES.WINDOWED_MED)


func _connect_signals() -> void:
	super()
	SignalManager.game_save_load_finished.connect(_on_game_save_loaded)
	_ui_level_controls.next_camera_requested.connect(cycle_cameras)
	_ui_level_controls.auto_camera_toggle_requested.connect(toggle_auto_cycle_cameras)
	_ui_level_controls.favorite_scene_requested.connect(favorite_scene)
	_ui_level_controls.next_scene_requested.connect(change_to_next_scene)
	SignalManager.camera_transition_finished.connect(_on_camera_transition_finished)


func _on_game_save_loaded() -> void:
	var favorite_scene_id: Global.LEVELS = ResourceManager.get_global_data("favorite_scene")
	if not favorite_scene_id:
		favorite_scene_id = Global.LEVELS.TEST
	
	SignalManager.change_scene_requested.emit(favorite_scene_id)


func _on_camera_transition_finished() -> void:
	if _auto_cycle_cameras:
		cycle_cameras()
