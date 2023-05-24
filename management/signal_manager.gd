class_name SignalMngr
extends Node

## This is intended to be used as an autoload singleton in conjuction with the
## rest of HR PSX.
##
## Use the signals here as an easy way to interact with the various scripts
## included in HR PSX in the intended way.


# Saves
signal game_save_requested(save_slot: int)
signal game_save_load_requested(save_slot: int)
signal game_save_load_finished()

# Resource Manager
signal music_load_requested(music_id: Global.MUSIC, path_to_resource: String)
signal ambience_load_requested(ambience_id: Global.AMBIENCES, path_to_resource: String)
signal sfx_load_requested(sfx_id: Global.SFX, path_to_resource: String)
signal screenshot_requested()

# Post processing
signal pp_default_shaders_changed(new_default_shaders: Array)
signal pp_default_shaders_enabled_changed(new_default_pp_enabled: bool)
signal pp_enabled_changed(shader: Global.SHADERS, enabled: bool)
signal pp_all_disabled()

# Scene transitions
signal change_scene_requested(level_id: Global.LEVELS)
signal fade_out_requested()
signal fade_in_requested()
signal fade_out_finished()
signal fade_in_finished()

# Gameplay
signal pause_allowed_changed(pause_allowed: bool)
signal paused_changed(paused: bool)
signal set_delayed(target: Object, property_name: String, property_value, wait_seconds: float)
signal time_scale_change_requested(time_scale: float, duration: float)
signal location_entered(location_name: String)

# CameraManager
signal camera_cut_requested(to_camera: Camera3D)
signal camera_return_cut_requested()
signal camera_transition_requested(to_camera: Camera3D, duration: float)
signal camera_return_transition_requested(duration: float)
signal camera_transition_finished()
signal screenshake_requested(speed: float, strength: float, decay_rate: float)
signal screenshake_stop_requested()

# Instances
signal instance_requested(scene: PackedScene, location: Vector3)
signal instance_spawned(instance: Node)
signal enemy_spawned(enemy)
signal state_saver_freed(name: String, data: Dictionary)

# Player
signal player_died
signal player_health_changed(current_health: int, max_health: int)

# Progression
signal experience_gained(amount: int)
signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)

# Display
signal set_window_mode(new_window_mode: Global.WINDOW_MODES)
