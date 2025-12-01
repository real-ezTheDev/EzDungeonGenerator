class_name Triangle extends Resource

@export var points: Array[Vector2]

func get_edges() -> Array[Triangle]:
	var edge_a := Triangle.new()
	var edge_b := Triangle.new()
	var edge_c := Triangle.new()
	
	edge_a.points = [
		points[0],
		points[1]
	]
	edge_b.points = [
		points[1],
		points[2]
	]
	edge_c.points = [
		points[0],
		points[2]
	]
	
	return [edge_a, edge_b, edge_c]

func hashcode() -> String:
	points.sort()
	return str(points)

func equals(other: Triangle) -> bool:
	return hashcode() == other.hashcode()
