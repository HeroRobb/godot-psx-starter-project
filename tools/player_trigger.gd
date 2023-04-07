class_name PlayerTrigger
extends PlayerDetector


enum TRIGGER_TYPES {
	ENTER_EXIT,
	INTERACT,
}

@export var triggered_node_path: NodePath
## Enter exit will trigger on player entered and player exit. Interact will trigger if the player calls the interact function.
@export var trigger_type: TRIGGER_TYPES = TRIGGER_TYPES.ENTER_EXIT
## The name of the function that will be called on the node in [member:
@export var enter_function: String
@export var exit_function: String


func _ready() -> void:
	player_entered.connect(_on_player_entered)
	player_exited.connect(_on_player_exited)


func _on_player_entered() -> void:
	if triggered_node_path == null:
		printerr("Triggered node path not defined in PlayerTrigger")
	
	var triggered_node: Node = get_node_or_null(triggered_node_path)
	
	if not triggered_node:
		printerr("Triggered node not found by PlayerTrigger")
		return
	
	if trigger_type == TRIGGER_TYPES.INTERACT:
		SignalManager.interactable_available.emit(self)
		return
	
	if not triggered_node.has_method(enter_function):
		printerr("Node triggered by PlayerTrigger does not have function %s" % enter_function)
		return
	
	triggered_node.call(enter_function)


func _on_player_exited() -> void:
	if triggered_node_path == null:
		printerr("Triggered node path not defined in PlayerTrigger")
	
	var triggered_node: Node = get_node_or_null(triggered_node_path)
	
	if not triggered_node:
		printerr("Triggered node not found by PlayerTrigger")
		return
	
	if trigger_type == TRIGGER_TYPES.INTERACT:
		SignalManager.interactable_unavailable.emit(self)
		return
	
	if not triggered_node.has_method(exit_function):
		printerr("Node triggered by PlayerTrigger does not have function %s" % exit_function)
		return
	
	triggered_node.call(exit_function)
