extends Area3D

signal interacted_with

@export var is_active := true : set = set_is_active
@export var one_shot := false

@onready var _active_collision_layer_bit := collision_layer


func _on_ready():
	# call setter checked ready (doesn't seem to work in a `tool` script)
	self.is_active = self.is_active


func on_interacted_with():
	# print("[DEBUG] %s HAS BEEN INTERACTED WITH" % name)
	emit_signal("interacted_with")

	if self.one_shot:
		self.is_active = false


func set_is_active(new_active: bool):
	is_active = new_active
	collision_layer = self._active_collision_layer_bit if new_active else 0


func get_active_collision_layer_bit() -> int:
	return self._active_collision_layer_bit
