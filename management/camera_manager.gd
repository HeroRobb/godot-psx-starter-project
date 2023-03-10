class_name CameraManager
extends Node


var _transitioning: bool = false
var _main_camera: Camera3D
var _previous_camera: Camera3D

@onready var trans_camera: Camera3D = $TransCamera


func _ready() -> void:
	SignalManager.camera_transition_needed.connect(transition_to)


func switch_to_camera(to_camera: Camera3D) -> void:
	_previous_camera = _main_camera
	_main_camera = to_camera
	
	if _previous_camera:
		_previous_camera.current = false
	_main_camera.current = true


func transition_to(to_camera: Camera3D, duration: float = 1.0) -> void:
	if _transitioning: return
	
	trans_camera.fov = _main_camera.fov
	trans_camera.cull_mask = _main_camera.cull_mask
	
	trans_camera.global_transform = _main_camera.global_transform
	
	_main_camera.current = false
	trans_camera.current = true
	
	_transitioning = true
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(trans_camera, "global_transform", to_camera.global_transform, duration)
	tween.tween_property(trans_camera, "fov", to_camera.fov, duration)
	
	await tween.finished
	
	to_camera.current = true
	_main_camera = to_camera
	_transitioning = false
	SignalManager.camera_transition_finished.emit()
