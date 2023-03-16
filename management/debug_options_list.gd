class_name DebugOptionsList
extends Resource

## Data structure for DebugMenu that contains DebugCategories and DebugOptions
##
## DebugMenu should handle all of this so I wouldn't dig too much into it unless
## you need to do something not available with normal functionality.


const _MAIN_CATEGORY_NAME = "Debug Menu"
const _ACCEPTABLE_CATEGORY_TYPES = [TYPE_STRING, TYPE_INT]

var _data: Array[DebugCategory]


func _init() -> void:
	var main_category = DebugCategory.new(_MAIN_CATEGORY_NAME, 0, null)
	_data.append(main_category)


func call_debug_function(category_name_or_index, option_index: int) -> void:
	var category: DebugCategory = _get_category(category_name_or_index)
	var option: DebugOption = category.get_option(option_index)
	if not option:
		return
	option.debug_call()


func add_category(name: String, parent_index_or_name = null) -> void:
	var duplicate_check: DebugCategory = _get_category(name)
	
	if duplicate_check:
		return
	
	var parent_category: DebugCategory
	
	if parent_index_or_name:
		parent_category = _get_category(parent_index_or_name)
	else:
		parent_category = _get_main_category()
	
	var new_category: DebugCategory = DebugCategory.new(name, _data.size(), parent_category)
	_data.append(new_category)


func add_option(category_index_or_name, option_name: String, function: Callable, parameters: Array) -> void:
	var category: DebugCategory = _get_category(category_index_or_name)
	var new_option: DebugOption = DebugOption.new(option_name, function, parameters)
	
	category.add_option(new_option)


func get_index(category_name: String) -> int:
	var category: DebugCategory = _get_category_from_name(category_name)
	return category.index


func get_category_option_names(category_name_or_index) -> Array:
	var category: DebugCategory = _get_category(category_name_or_index)
	var options_array: Array = category.get_options()
	var name_array: Array = []
	
	for option in options_array:
		var this_option: DebugOption = option
		name_array.append(this_option.option_name)
	
	return name_array


func _get_category(category_name_or_index) -> DebugCategory:
	assert(_ACCEPTABLE_CATEGORY_TYPES.has( typeof(category_name_or_index) ), "Tried to add a category, but category_index_or_name must be an int or a String.")
	var category: DebugCategory
	match typeof(category_name_or_index):
		TYPE_INT:
			category = _get_category_from_index(category_name_or_index)
		TYPE_STRING:
			category =  _get_category_from_name(category_name_or_index)
	
	return category


func _get_category_from_name(name: String) -> DebugCategory:
	var found_category: DebugCategory = null
	
	for category in _data:
		if category.category_name == name:
			found_category = category
			break
	
	return found_category


func _get_category_from_index(index: int) -> DebugCategory:
	var category: DebugCategory = null
	if index < _data.size() or index >= 0:
		category = _data[index]
	return category


func _get_main_category() -> DebugCategory:
	return _get_category_from_index(0)


class DebugOption:
	
	
	var option_name: String
	
	var _function: Callable
	
	
	func _init(new_option_name: String, function: Callable, parameters: Array = []) -> void:
		option_name = new_option_name
		_function = function
		
		if parameters.is_empty():
			return
		
		_function = _function.bindv(parameters)
	
	
	func debug_call() -> void:
		_function.call()


class DebugCategory:
	
	
	var category_name: String
	var parent_category: DebugCategory
	var index: int
	
	var _options: Array[DebugOption]
	
	
	func _init(name: String, new_index: int, parent: DebugCategory) -> void:
		category_name = name
		_options = []
		parent_category = parent
		index = new_index
	
	
	func add_option(option: DebugOption) -> void:
		_options.append(option)
	
	
	func get_options() -> Array:
		return _options
	
	
	func get_option(id: int) -> DebugOption:
		var option: DebugOption = null
		if id < _options.size() and id >= 0:
			option = _options[id]
		
		return option
	
	
	func clear_options() -> void:
		_options.clear()
	
	func size() -> int:
		return _options.size()
