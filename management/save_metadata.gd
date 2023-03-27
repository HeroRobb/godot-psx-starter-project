class_name SaveMetadata
extends Resource

@export var save_1_hash: String = "fa54s6df15a 61a56d"
@export var save_2_hash: String = ":fjdaf d4f65a1 56w51f "
@export var save_3_hash: String = "fidijefudhalfdaj; kfgld;af"


func get_hash(save_slot: int) -> String:
	assert(save_slot <= 3, "tried to get hash for save slot that doesn't exist")
	
	var hash: String = ""
	match save_slot:
		1: hash = save_1_hash
		2: hash = save_2_hash
		3: hash = save_3_hash
	
	return hash


func set_hash(save_slot: int, new_hash: String) -> void:
	assert(save_slot <= 3, "tried to set hash for save slot that doesn't exist")
	
	match save_slot:
		1: save_1_hash = new_hash
		2: save_2_hash = new_hash
		3: save_3_hash = new_hash
