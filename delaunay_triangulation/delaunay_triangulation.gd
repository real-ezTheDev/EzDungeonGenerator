class_name DelaunayTriangulation extends Node

signal point_added(point: Vector2)
signal circle_drawn(circle: Circle)
signal new_triangles_drawn(triangle: Array[Triangle])
signal next()

const TRIANGULATION_EDGE = preload("uid://ugbb2t2dy8rx")

func next_step():
	next.emit()

func triangulate(points: Array[Node2D]) -> Array[Triangle]:
	var super_triangle := get_super_triangle(points)
	var triangles: Array[Triangle] = [
		super_triangle
	]

	for point in points:
		#new_triangles_drawn.emit(triangles)
		
		var adding_point: Vector2 = point.position
		
		point_added.emit(adding_point)
		
		var bad_triangles: Array[Triangle] = []
		var updated_triangles: Array[Triangle] = []
		
		# check if the new point is making any of the triangle fail Delaunay Triangulation check.
		for triangle in triangles:
			if _is_delaunay_triangle(adding_point, triangle):
				updated_triangles.push_back(triangle)
			else:
				bad_triangles.push_back(triangle)
		
		var new_triangles: Dictionary[String, Triangle] = {}
		
		for bad_triangle in bad_triangles:
			var edges := bad_triangle.get_edges()
			for edge in edges:
				if new_triangles.has(edge.hashcode()):
					new_triangles.erase(edge.hashcode())
				else:
					new_triangles[edge.hashcode()] = edge
				
		for new_triangle in new_triangles.values():
			new_triangle.points.push_back(adding_point)
			updated_triangles.push_back(new_triangle)
			
		triangles = updated_triangles
	
	var sanitized_triangles: Dictionary[String, Triangle] = {}

	for triangle in triangles:
		for edge in triangle.get_edges():
			sanitized_triangles[edge.hashcode()] = edge

			for super_point in super_triangle.points:
				if edge.points.has(super_point):
					sanitized_triangles.erase(edge.hashcode())
					break
	
	new_triangles_drawn.emit(sanitized_triangles.values())
	return sanitized_triangles.values()
	
func get_super_triangle(points: Array[Node2D]) -> Triangle:
	if points.is_empty():
		return null
	var margin: float = 50
	
	var lowest_x: float = points[0].position.x
	var highest_x: float = points[0].position.x
	var lowest_y: float = points[0].position.y
	var highest_y: float = points[0].position.y
	
	for point in points:
		if point.position.x < lowest_x:
			lowest_x = point.position.x
			
		if point.position.x > highest_x:
			highest_x = point.position.x
		
		if point.position.y < lowest_y:
			lowest_y = point.position.y
			
		if point.position.y > highest_y:
			highest_y = point.position.y
	
	# add_margin
	lowest_x -= margin
	highest_x += margin
	lowest_y -= margin
	highest_y += margin
	
	var x_midpoint = (lowest_x + highest_x)/2
	var boundary_size := Vector2(highest_x - lowest_x, highest_y - lowest_y)
	
	var super_triangle: Triangle = Triangle.new()
	
	super_triangle.points = [
		Vector2(x_midpoint, lowest_y - boundary_size.y),
		Vector2(x_midpoint - boundary_size.x, highest_y),
		Vector2(x_midpoint + boundary_size.x, highest_y)
	]

	return super_triangle
	
func _is_delaunay_triangle(point: Vector2, triangle: Triangle) -> bool:
	var circum_circle := _calc_circum_circle(triangle)
	
	#circle_drawn.emit(circum_circle)
	
	return point.distance_to(circum_circle.position) > circum_circle.radius
	
func _calc_circum_circle(triangle: Triangle) -> Circle:
	var circle: = Circle.new() as Circle
	
	triangle.points.sort_custom(func (_a: Vector2, _b: Vector2):
		return _a.x < _b.x)
	
	var offset := triangle.points[0]
	var a : Vector2 = triangle.points[0] - offset
	var b : Vector2 = triangle.points[1] - offset
	var c : Vector2 = triangle.points[2] - offset
	
	circle.position.x = (c.y*(b.x*b.x + b.y*b.y) - b.y*(c.x*c.x+c.y*c.y))
	circle.position.x /= 2 * (b.x*c.y - b.y*c.x)
	circle.position.y = (b.x*(c.x*c.x + c.y*c.y) - c.x*(b.x*b.x + b.y*b.y))/( 2 * (b.x*c.y - b.y*c.x))
	
	circle.radius = a.distance_to(circle.position)
	
	circle.position += offset
	return circle
