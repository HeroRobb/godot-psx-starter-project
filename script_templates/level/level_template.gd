# meta_description: Contains all of the functions you should override
# meta_default: true


extends _BASE_


func _ready() -> void:
	super()
#	Add the rest of what you need to the ready function after the super() call.


## This is the logic that will be called with the previous scenes id from
## [member Glbl.LEVELS] so you can have run logic based on the previous
## level/scene. Keep in mind that this runs after [method ready].
func initialize_level(previous_scene_id: Global.LEVELS) -> void:
	_player_container.move_player_to_spawn_position(previous_scene_id)
