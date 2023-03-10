class_name ScreenSpaceShaderManager
extends Control


var _default_shaders_enabled: bool = false
var _default_shaders: Array[Global.SHADERS] = [] : set = set_default_shaders

@onready var _blur_buffer: BackBufferCopy = $BlurBuffer
@onready var _color_precision_buffer: BackBufferCopy = $ColorPrecisionBuffer
@onready var _crt_buffer: BackBufferCopy = $CRTBuffer
@onready var _glitch_buffer: BackBufferCopy = $GlitchBuffer
@onready var _grain_buffer: BackBufferCopy = $GrainBuffer
@onready var _sharpness_buffer: BackBufferCopy = $SharpnessBuffer
@onready var _vhs_buffer: BackBufferCopy = $VHSBuffer

@onready var _all_buffers: Dictionary = {
	Global.SHADERS.BLUR: _blur_buffer,
	Global.SHADERS.COLOR_PRECISION: _color_precision_buffer,
	Global.SHADERS.CRT: _crt_buffer,
	Global.SHADERS.GRAIN: _grain_buffer,
	Global.SHADERS.GLITCH: _glitch_buffer,
	Global.SHADERS.SHARPNESS: _sharpness_buffer,
	Global.SHADERS.VHS: _vhs_buffer,
}


func _ready() -> void:
	SignalManager.pp_default_shaders_changed.connect(set_default_shaders)
	SignalManager.pp_default_shaders_enabled_changed.connect(set_default_shaders_enabled)
	SignalManager.pp_enabled_changed.connect(set_pp_enabled)
	SignalManager.pp_all_disabled.connect(disable_all)
	disable_all()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		_default_shaders_enabled = not _default_shaders_enabled
		set_default_shaders_enabled(_default_shaders_enabled)


func set_default_shaders(new_default_shaders: Array) -> void:
	_default_shaders = new_default_shaders


func set_default_shaders_enabled(new_enabled: bool) -> void:
	for shader in _default_shaders:
		set_pp_enabled(shader, new_enabled)


func set_pp_enabled(shader: Global.SHADERS, enabled: bool) -> void:
	if not _all_buffers.has(shader):
		return
	
	var back_buffer: BackBufferCopy = _all_buffers[shader]
	back_buffer.visible = enabled


func disable_all() -> void:
	for child in get_children():
		if child is BackBufferCopy:
			child.hide()
