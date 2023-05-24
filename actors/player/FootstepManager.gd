extends Node

enum STEPS {
	GRASS,
	METAL,
	SAND,
}

const WALKSTEP_TIME := 0.6
const SPRINTSTEP_TIME := 0.4
const METAL_VOLUME := -5.0
const SAND_VOLUME := -15.0

@export(NodePath) onready var _agent = get_node(_agent) as CharacterBody3D

var active := false : set = set_active
var current_step_type: int = STEPS.GRASS

var _step_volume := -20.0
var _steps := {
	STEPS.GRASS: [
		Global.SFX.STEP_GRASS1,
		Global.SFX.STEP_GRASS2,
		Global.SFX.STEP_GRASS3,
	]
}
var _step_volumes := {
	STEPS.GRASS: -5.0,
	STEPS.METAL: -5.0,
	STEPS.SAND: -15.0,
}

@onready var _footstep_timer := $FootstepTimer


func _ready() -> void:
# warning-ignore-all:return_value_discarded
	SignalManager.connect("footsteps_area_entered",Callable(self,"_on_footsteps_area_entered"))
	SignalManager.connect("player_playable_changed",Callable(self,"_on_playable_changed"))
	
	if _agent:
		set_active(true)


func _physics_process(_delta: float) -> void:
	if abs(_agent.flat_velocity) > 0.1 and _agent.is_on_floor() and _footstep_timer.is_stopped():
		_play_footstep()


func _play_footstep() -> void:
	var rand_number := (randi() % 3) + 1
	if _agent.sprinting:
		_footstep_timer.wait_time = SPRINTSTEP_TIME
	else:
		_footstep_timer.wait_time = WALKSTEP_TIME
	
	var footstep_id = _get_random_current_footstep_sound_id()
	SoundManager.play_sfx(_steps[current_step_type][footstep_id], randf_range(0.8, 1.2), _step_volume)
	_footstep_timer.start()


func _stop_footsteps() -> void:
	_footstep_timer.stop()


func set_active(new_active: bool) -> void:
	if active != new_active:
		active = new_active
		set_physics_process(active)


func _get_random_current_footstep_sound_id() -> int:
	randomize()
	var random_index := int( round( randf_range(0, _steps[current_step_type].size()) ) )
	return random_index


func _on_footsteps_area_entered(new_footstep_id: int) -> void:
	current_step_type = new_footstep_id
	
	_step_volume = _step_volumes[current_step_type]


func _on_playable_changed(new_playable: bool) -> void:
	set_physics_process(new_playable)
	
	if not new_playable:
		_stop_footsteps()
