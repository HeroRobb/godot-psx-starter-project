class_name CameraManager
extends Node

## A node included in HR PSX for easy camera cuts and smooth camera transitions
##
## This node is intended to be used in conjunction with the autoload singleton
## [SignalMngr] in res://management from HR PSX. Use the signals
## camera_cut_needed, camera_transition_needed, camera_transition_needed,
## camera_return_cut_needed, and camera_return_transition_needed to use this
## node wherever it is. For base functionality, add cameras in the various
## places you would need them in a level and use those signals in your level
## logic.


var _transitioning: bool = false
var _main_camera: Camera3D
var _previous_camera: Camera3D

@onready var trans_camera: Camera3D = $TransCamera


func _ready() -> void:
	SignalManager.camera_cut_needed.connect(cut_to_camera)
	SignalManager.camera_return_cut_needed.connect(return_cut)
	SignalManager.camera_transition_needed.connect(transition_to_camera)
	SignalManager.camera_return_transition_needed.connect(return_transition)


## This function does a hard cut to the to_camera, essentially making the
## to_camera current. It is intended to be used with the camera_cut_needed
## signal from res://management/SignalManager.gd when SignalManager is an
## autoload singleton.
func cut_to_camera(to_camera: Camera3D) -> void:
	_previous_camera = _main_camera
	_main_camera = to_camera
	
	if _previous_camera:
		_previous_camera.current = false
	_main_camera.current = true


## This function does a smooth transition to the to_camera taking
## duration_seconds to finish. After the camera has fully transitioned,
## SignalManager will emit the camera_transition_finished signal.
func transition_to_camera(to_camera: Camera3D, duration_seconds: float = 1.0) -> void:
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
	tween.tween_property(trans_camera, "global_transform", to_camera.global_transform, duration_seconds)
	tween.tween_property(trans_camera, "fov", to_camera.fov, duration_seconds)
	
	await tween.finished
	
	to_camera.current = true
	_main_camera = to_camera
	_transitioning = false
	SignalManager.camera_transition_finished.emit()


## This function does a hard cut to the previous camera. If there wasn't a
## previous camera, it will print an error to the console and do nothing.
func return_cut() -> void:
	if not _previous_camera:
		printerr("Tried to cut to the previous camera when the previous camera does not yet exist.")
		return
	
	cut_to_camera(_previous_camera)


## This function does a smooth transition to the previous camera. If there
## wasn't a previous camera, it will print an error to the console and do
## nothing.
func return_transition(duration_seconds: float = 1.0) -> void:
	if not _previous_camera:
		printerr("Tried to transition to the previous camera when the previous camera does not yet exist.")
		return
	
	transition_to_camera(_previous_camera, duration_seconds)
