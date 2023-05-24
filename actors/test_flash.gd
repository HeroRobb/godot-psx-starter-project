extends Node3D

var _white_tex := preload("res://materials/textures/white_square.png")
var _green_tex := preload("res://materials/textures/GreenDemon_Texture.png")

var _flashing := false

@onready var _mesh := $Demon/MonsterArmature/Skeleton3D/Demon001


func _ready() -> void:
	$Timer.connect("timeout",Callable(self,"_flash"))


func _flash() -> void:
	var new_tex
	if _flashing:
		new_tex = _green_tex
	else:
		new_tex = _white_tex
	
	_mesh.mesh.surface_get_material(0).set_shader_parameter("albedoTex", new_tex)
	_flashing = not _flashing
