# meta_description: Contains all of the functions you should override
# meta_default: true


extends Level


enum LEVEL_TYPE {PEACEFUL, ADVENTURE}

## This is the name of the level/scene. This is primarily used in conjunction
## with [member show_location_name] to show the text of the location in the
## center of the screen.
@export var location_name: String
## If this value is set to true, text displaying [member location_name] will
## appear in the center of the screen when the level loads.
@export var show_location_name: bool = false


func _ready() -> void:
	super()
	
	if not show_location_name:
		return
	
	_show_location_name()
	
	var previous_scene_id = ResourceManager.get_global_data("previous_scene_id")
	if previous_scene_id:
		initialize_level(previous_scene_id)


## Shows the text of [member location_name] in the center of the screen.
func _show_location_name() -> void:
	SignalManager.location_entered.emit(location_name)


## This is the logic that will be called with the previous scenes id from
## [member Glbl.LEVELS] so you can have run logic based on the previous
## level/scene. Keep in mind that this runs after [method ready].
func initialize_level(previous_scene_id: Global.LEVELS) -> void:
	_player_container.move_player_to_spawn_position(previous_scene_id)


func _heal_player() -> void:
	SignalManager.emit_signal("player_healed")
