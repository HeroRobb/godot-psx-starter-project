extends Node3D


#onready var pizza_slice := $Sliced_pizza


func _ready() -> void:
# warning-ignore-all:return_value_discarded
	SignalManager.connect("item_picked_up",Callable(self,"_on_item_picked_up"))
	SignalManager.connect("item_dropped",Callable(self,"_on_item_dropped"))


func _hold_item(_item_id: String) -> void:
	_hide_all_items()
#	match item_id:
#		"pizza_slice":
#			pizza_slice.show()


func _drop_item(_item_id: String) -> void:
	_hide_all_items()


func _hide_all_items() -> void:
	for child in get_children():
		child.hide()


func _on_item_picked_up(item_id: String) -> void:
	_hold_item(item_id)


func _on_item_dropped(item_id: String) -> void:
	_drop_item(item_id)
