class_name Level3D
extends Node3D

## A Node which can be used to create inherited scenes as levels for your game
##
## You should be able to make most of the generic functionality you need by
## using the editor for every level/scene that involves gameplay. You should
## extend this script for each level/scene to have the logic of your
## level/scene.


@export_category("Level info")
## This value is the id of the level/scene from [member Glbl.LEVELS]. It can be
## used for other Nodes to know what level/scene this is. I may take this out.
## Doesn't seem that useful.
@export var level_id: Global.LEVELS = Global.LEVELS.TEST
## If this value is set to true, the scene will begin with the default shaders
## set in [GameMngr] active. If it is set to false, no shaders will be shown
## and you'll have to set them up yourself in the ready function.
@export var use_default_shaders: bool = true


@export_category("Sound")
## This is the starting ambience that will be played on load. The ID's are from
## [member Glbl.Ambiences] so you will need to have edited that script first.
@export var starting_ambience_id: Global.AMBIENCES = Global.AMBIENCES.NONE
## This is the id of the music that will be played on load. The ID's are from
## [member Glbl.MUSIC] so you will need to have edited that script first.
@export var starting_music_id: Global.MUSIC = Global.MUSIC.NONE
## How loud the starting ambience will be. This is helpful if you have sound
## files that have irritatingly large differences in volume.
@export_range(-40, 40, 0.5) var starting_ambience_db = 0.0
## How loud the starting music will be. This is helpful if you have sound
## files that have irritatingly large differences in volume.
@export_range(-40, 40, 0.5) var starting_music_db = 0.0

var _current_music_id: int
var _current_ambience_id: int

@onready var _player_container: PlayerContainer = $PlayerContainer
@onready var _geometry_container: Node3D = $GeometryContainer
@onready var _area_container: AreaContainer = $AreaContainer
@onready var _camera_manager: CameraManager3D = $CameraManager3D


func _ready() -> void:
	_connect_signals()
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	SoundManager.play_ambience(starting_ambience_id)
	SoundManager.play_music(starting_music_id)
	
	if use_default_shaders:
		SignalManager.pp_default_shaders_enabled_changed.emit(true)
	else:
		SignalManager.pp_all_disabled.emit()


func _connect_signals() -> void:
	SignalManager.instance_requested.connect(_on_instance_requested)
	var player = _player_container.get_player()
	for safety_net in _area_container.get_safety_nets():
		safety_net.player_entered.connect(_player_container.teleport_player_to_safety)


func _on_instance_requested(instance_scene: PackedScene, location: Vector3) -> void:
	var new_instance = instance_scene.instantiate()
	add_child(new_instance)
	new_instance.global_transform.origin = location
