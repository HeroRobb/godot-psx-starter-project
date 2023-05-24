class_name MapData
extends Resource


var paths: Array[PackedInt64Array]
var nodes: Dictionary

func set_paths(new_paths: Array[PackedInt64Array], points: Array[Vector2i]):
	paths = new_paths
	
	for path in paths:
		for id in path:
			nodes[id] = points[id]
