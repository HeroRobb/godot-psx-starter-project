class_name SignalMngr
extends Node

## This is intended to be used as an autoload singleton in conjuction with the
## rest of HR PSX.
##
## Use the signals here as an easy way to interact with the various scripts
## included in HR PSX in the intended way.


# Saves
signal game_save_loaded()

# Resource Manager
signal music_load_needed(music_id: Global.MUSIC, path_to_resource: String)
signal ambience_load_needed(ambience_id: Global.AMBIENCES, path_to_resource: String)
signal sfx_load_needed(sfx_id: Global.SFX, path_to_resource: String)

# Post processing
signal pp_default_shaders_changed(new_default_shaders: Array)
signal pp_default_shaders_enabled_changed(new_default_pp_enabled: bool)
signal pp_enabled_changed(shader: Global.SHADERS, enabled: bool)
signal pp_all_disabled()

# Scene transitions
signal change_scene_needed(level_id: Global.LEVELS)
signal fade_out_needed()
signal fade_in_needed()
signal fade_out_finished()
signal fade_in_finished()

# Gameplay
signal pause_allowed_changed(pause_allowed: bool)
signal paused_changed(paused: bool)
signal set_delayed(target: Object, property_name: String, property_value, wait_seconds: float)
signal screeenshake_needed(magnitude, duration: float, limit)
signal location_entered(location_name: String)

# CameraManager
signal camera_cut_needed(to_camera: Camera3D)
signal camera_return_cut_needed()
signal camera_transition_needed(to_camera: Camera3D, duration: float)
signal camera_return_transition_needed(duration: float)
signal camera_transition_finished()

# Instances
signal instance_needed(scene: PackedScene, location: Vector3)
signal enemy_spawned(enemy)
signal state_saver_freed(name: String, data: Dictionary)

# Player
signal player_died

# Display
signal set_window_mode(new_window_mode: Global.WINDOW_MODES)
