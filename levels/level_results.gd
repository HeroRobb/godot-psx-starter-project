extends Node3D


const TRANSITION_TIME: float = 6.0

@onready var _results_label: Label = $Results/CenterContainer/VBoxContainer/ResultsLabel
@onready var _camera_manager: CameraManager = $CameraManager
@onready var _camera1: Camera3D = $GeometryExample2/Camera3D
@onready var _camera2: Camera3D = $GeometryExample2/Camera3D2

var _camera_index: int = 1


func _ready() -> void:
	_camera_manager.transition_finished.connect(_on_camera_transition_finshed)
	
	_camera_manager.cut_to_camera(_camera1)
	_camera_manager.transition_to_camera(_camera2, TRANSITION_TIME)
	
	if ResourceManager.get_global_data("last_level_won"):
		_results_label.text = "YOU WON!"
		return
	
	_results_label.text = "YOU DIED!"


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		SignalManager.change_scene_requested.emit(Global.LEVELS.TEST)
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()


func _on_camera_transition_finshed() -> void:
	if _camera_index == 1:
		_camera_index = 0
		_camera_manager.transition_to_camera(_camera1, TRANSITION_TIME)
		return
	
	_camera_index = 1
	_camera_manager.transition_to_camera(_camera2, TRANSITION_TIME)
