class_name SaveGameManager
extends Node

## This node takes care of saving and loading game saves from disc.
##
## It's not done yet so it doesn't really work lol


const METADATA_FILE_NAME = "metadata"
const SAVE_EXTENSION = ".tres"
const METADATA_EXTENSION = ".res"

@export var save_directory: String = "saves"
@export var save_file_1_name: String = "save_data_1"
@export var save_file_2_name = "save_data_2"
@export var save_file_3_name = "save_data_3"


func save_data(save_data: GameData, save_slot: int) -> void:
	if not save_directory.is_empty():
		save_directory += "/"
	var file_path: String = _get_save_path(save_slot)
	SignalManager.screenshot_requested.emit()
	ResourceSaver.save(save_data, file_path)
	_update_metadata(save_slot)


func get_data(save_slot: int, force_corrupted: bool = false) -> GameData:
	var file_path: String = _get_save_path(save_slot)
	
	if not ResourceLoader.exists(file_path):
		return null
	
	var loaded_data: GameData = ResourceLoader.load(file_path)
	var metadata_hash = _get_hash_from_metadata(save_slot)
	
	if not metadata_hash == FileAccess.get_md5(file_path):
		printerr("portal data is corrupted and cannot be used")
		
		if force_corrupted:
			return loaded_data
		
		return null
	
	return loaded_data


func delete_data(save_slot: int) -> void:
	var file_path: String = _get_save_path(save_slot)
	
	if not ResourceLoader.exists(file_path):
		return
	
	
	OS.move_to_trash(file_path)


func _update_metadata(save_slot: int) -> void:
	var metadata: SaveMetadata = _get_metadata()
	var new_hash := _get_hash_from_file(save_slot)
	
	metadata.set_hash(save_slot, new_hash)
	
	var metadata_path: String = _get_metadata_path()
	ResourceSaver.save(metadata, metadata_path)


func _create_new_metadata() -> void:
	var metadata = SaveMetadata.new()
	var metadata_path: String = _get_metadata_path()
	ResourceSaver.save(metadata, metadata_path)


func _get_metadata() -> Resource:
	var metadata_path: String = _get_metadata_path()
	if not ResourceLoader.exists(metadata_path):
		_create_new_metadata()
	
	return ResourceLoader.load(metadata_path)


func _get_hash_from_metadata(save_slot: int) -> String:
	var metadata: SaveMetadata = _get_metadata()
	var metadata_hash: String = metadata.get_hash(save_slot)
	
	return metadata_hash


func _get_hash_from_file(save_slot: int) -> String:
	var file_path: String = _get_save_path(save_slot)
	var md5: String = FileAccess.get_md5(file_path)
	return md5


func _get_save_path(save_slot: int) -> String:
	assert(save_slot <= 3, "tried to get path for save slot that doesn't exist")
	
	var save_directory_path = "user://" + save_directory
	
	if not DirAccess.dir_exists_absolute(save_directory_path):
		DirAccess.make_dir_recursive_absolute(save_directory_path)
	
	var file_name: String
	
	match save_slot:
		1: file_name = save_file_1_name
		2: file_name = save_file_2_name
		3: file_name = save_file_3_name
	
	var file_path: String = save_directory_path + file_name + SAVE_EXTENSION
	return file_path


func _get_metadata_path() -> String:
	var file_path: String = "user://" + save_directory + METADATA_FILE_NAME + METADATA_EXTENSION
	return file_path
