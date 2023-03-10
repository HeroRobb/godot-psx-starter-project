extends Node


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
signal pause_changed(paused: bool)
signal set_delayed(target: Object, property_name: String, property_value, wait_seconds: float)
signal screeenshake_needed(magnitude, duration: float, limit)

# Cameras
signal camera_transition_needed(to_camera_or_marker, duration: float)
signal camera_transition_finished()

# Instances
signal instance_needed(scene: PackedScene, location: Vector3)
signal enemy_spawned(enemy)
signal state_saver_freed(name: String, data: Dictionary)

# Player
signal player_died

# Display
signal set_window_mode(new_window_mode: Global.WINDOW_MODES)
