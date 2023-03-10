class_name Level
extends Node3D


enum LEVEL_TYPE {
	ADVENTURE,
	PEACEFUL,
}

const SHOW_LOCATION_WAIT_TIME = 1.5
const POST_INITIALIZE_WAIT_TIME = 0.5

@export_category("Level info")
@export var level_id: Global.LEVELS = Global.LEVELS.TEST
@export var location_name: String
@export var level_type: LEVEL_TYPE = LEVEL_TYPE.ADVENTURE

@export_category("Sound")
@export var starting_ambience_id: Global.AMBIENCES = Global.AMBIENCES.NONE
@export var starting_music_id: Global.MUSIC = Global.MUSIC.NONE
@export_range(-40, 40, 0.5) var starting_ambience_db = 0.0
@export_range(-40, 40, 0.5) var starting_music_db = 0.0

var _current_music_id: int
var _current_ambience_id: int

@onready var _player_container: PlayerContainer = $PlayerContainer
@onready var _geometry_container: Node3D = $GeometryContainer
@onready var _area_container: AreaContainer = $AreaContainer
@onready var _camera_manager: CameraManager = $CameraManager
@onready var _initialize_timer: Timer = $InitializeTimer


func _ready() -> void:
	_connect_signals()
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	_initialize_timer.wait_time = POST_INITIALIZE_WAIT_TIME
	_initialize_timer.one_shot = true
	
	SoundManager.play_ambience(starting_ambience_id, starting_ambience_db)
	SoundManager.play_music(starting_music_id, starting_music_db)
	
	if level_type == LEVEL_TYPE.PEACEFUL:
		_heal_player()
	
	_set_fall_damage()
	
	SignalManager.emit_signal("health_ui_visibility_changed", true)
	_show_location_name()
	var previous_scene_id = ResourceManager.get_global_data("previous_scene_id")
	initialize_level(previous_scene_id)


func initialize_level(previous_scene_id: int) -> void:
	_player_container.move_player_to_spawn_position(previous_scene_id)


func _set_fall_damage() -> void:
	var fall_damage: int
	
	if level_type == LEVEL_TYPE.ADVENTURE:
		fall_damage = 1
	elif level_type == LEVEL_TYPE.PEACEFUL:
		fall_damage = 0
	
	_player_container.set_fall_damage(fall_damage)


func _heal_player() -> void:
	SignalManager.emit_signal("player_healed")


func _show_location_name() -> void:
	SignalManager.emit_signal("location_entered", location_name)


func _connect_signals() -> void:
	SignalManager.instance_needed.connect(_on_instance_needed)
	var player = _player_container.get_player()
	for safety_net in _area_container.get_safety_nets():
		safety_net.player_entered.connect(_player_container.teleport_player_to_safety)


func _on_instance_needed(instance_scene: PackedScene, location: Vector3) -> void:
	var new_instance = instance_scene.instantiate()
	add_child(new_instance)
	new_instance.global_transform.origin = location
