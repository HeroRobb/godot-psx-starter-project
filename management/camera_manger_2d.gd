class_name CameraManager2D
extends Node

## A node included in HR PSX for easy camera cuts and smooth camera transitions
##
## This node is intended to be used in conjunction with the autoload singleton
## [SignalMngr] in res://management from HR PSX. Use the signals
## camera_cut_requested, camera_transition_requested, camera_transition_requested,
## camera_return_cut_requested, and camera_return_transition_requested to use this
## node wherever it is. For base functionality, add cameras in the various
## places you would need them in a level and use those signals in your level
## logic.


var _transitioning: bool = false
var _main_camera: Camera2D: set = _set_main_camera
var _previous_camera: Camera2D

@onready var _trans_camera: Camera2D = $TransCamera
@onready var _screenshake: Screenshake = $Screenshake


func _ready() -> void:
	SignalManager.camera_cut_requested.connect(cut_to_camera)
	SignalManager.camera_return_cut_requested.connect(return_cut)
	SignalManager.camera_transition_requested.connect(transition_to_camera)
	SignalManager.camera_return_transition_requested.connect(return_transition)


## This function does a hard cut to the to_camera, essentially making the
## to_camera enabled. It is intended to be used with the camera_cut_requested
## signal from res://management/SignalManager.gd when SignalManager is an
## autoload singleton.
func cut_to_camera(to_camera: Camera2D) -> void:
	_previous_camera = _main_camera
	_main_camera = to_camera
	
	if _previous_camera:
		_previous_camera.enabled = false
	_main_camera.enabled = true


## This function does a smooth transition to the to_camera taking
## duration_seconds to finish. After the camera has fully transitioned,
## SignalManager will emit the camera_transition_finished signal.
func transition_to_camera(to_camera: Camera2D, duration_seconds: float = 1.0) -> void:
	if _transitioning or to_camera == _main_camera: return
	
	_trans_camera.fov = _main_camera.fov
	_trans_camera.cull_mask = _main_camera.cull_mask
	
	_trans_camera.global_transform = _main_camera.global_transform
	
	_main_camera.enabled = false
	_trans_camera.enabled = true
	_screenshake.camera = _trans_camera
	
	_transitioning = true
	
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_parallel()
	tween.tween_property(_trans_camera, "global_transform", to_camera.global_transform, duration_seconds)
	tween.tween_property(_trans_camera, "fov", to_camera.fov, duration_seconds)
	
	await tween.finished
	
	_main_camera = to_camera
	await get_tree().process_frame
	to_camera.enabled = true
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


func _set_main_camera(new_main_camera) -> void:
	_main_camera = new_main_camera
	_screenshake.camera = _main_camera
