extends Node2D


@export var _end_screen_scene: PackedScene

@onready var _camera_manager: CameraManager2D = $CameraManger2D
@onready var _player_camera: Camera2D = $PlayerCamera


func _ready():
	SoundManager.play_music(Global.MUSIC.CARNELIA, -10)
	_camera_manager.cut_to_camera(_player_camera)
	
	SignalManager.instance_spawned.connect(_on_instance_spawned)
	SignalManager.player_died.connect(_on_player_died)
	
	SignalManager.screenshake_requested.emit(4, 16, 0)
	SignalManager.experience_gained.emit(0)


func _on_instance_spawned(instance: Node) -> void:
	add_child(instance)


func _on_player_died() -> void:
	var end_screen_instance: EndScreen = _end_screen_scene.instantiate()
	add_child(end_screen_instance)
	end_screen_instance.set_loss()
