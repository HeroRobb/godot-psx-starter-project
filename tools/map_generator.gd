class_name MapGenerator
extends Resource


func generate(plane_length: int, node_count: int, path_count: int) -> MapData:
	randomize()
	
	# generate points on a grid
	var points: Array[Vector2i]
	var start_point:Vector2i = Vector2i(0, plane_length / 2)
	var end_point: Vector2i = Vector2i(plane_length, plane_length / 2)
	points.append(start_point)
	points.append(end_point)
	
	var center: Vector2i = Vector2i(plane_length / 2, plane_length / 2)
	
	for i in range(node_count):
		while true:
			var point: Vector2i = Vector2i(randi_range(0, plane_length - 1), randi_range(0, plane_length - 1))
			
			var distance_from_center: int = (point - center).length_squared()
			var is_in_circle: bool = distance_from_center <= plane_length * plane_length / 4
			
			if not points.has(point) and is_in_circle:
				points.append(point)
				break
	
	# connect the points into a graph
	var pool: PackedVector2Array = PackedVector2Array(points)
	var triangles: PackedInt32Array = Geometry2D.triangulate_delaunay(pool)
	
	# find A* paths from start to finish
	var astar = AStar2D.new()
	for i in range(points.size()):
		astar.add_point(i, points[i])
	
	for i in range(triangles.size() / 3):
		var p1: int = triangles[i * 3]
		var p2: int = triangles[i * 3 + 1]
		var p3: int = triangles[i * 3 + 2]
		
		astar.connect_points(p1, p2)
		astar.connect_points(p1, p3)
		astar.connect_points(p2, p3)
	
	var paths: Array[PackedInt64Array]
	
	for i in range(path_count):
		var id_path: PackedInt64Array = astar.get_id_path(0, 1)
		
		if id_path.size() == 0:
			break
		
		paths.append(id_path)
		
		# generate unique paths and remove nodes
		for j in range( randi_range(1, 2)) :
			var index = randi_range(0, id_path.size()- 2)
			
			var id: int = id_path[index]
			astar.set_point_disabled(id)
	
	var data: MapData = MapData.new()
	data.set_paths(paths, points)
	return data
