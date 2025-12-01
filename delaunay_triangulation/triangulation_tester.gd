extends Node2D

@onready var delaunay_triangulation: DelaunayTriangulation = $DelaunayTriangulation

var points: Array[Node2D] = []
var super_triangle: Triangle

var _draw_points: Array[Vector2] = []
var _draw_triangle: Array[Triangle] = []
var _draw_circle: Circle

func _input(event: InputEvent):
	if event.is_action_pressed("ui_accept"):
		delaunay_triangulation.next.emit()

func _ready():
	run()

func clear():
	for point in points:
		point.queue_free()
	_draw_points =[]
	points = []
		
func run():
	var point_count := 20
	
	for i in point_count:
		var new_point := Node2D.new()
		new_point.position = Vector2(randi_range(100,1920 - 100), randi_range(100, 1080-100))
		points.push_back(new_point)
		
	var edges: Array[Triangle] = delaunay_triangulation.triangulate(points)
	var point_to_edges: Dictionary[Vector2, Array] = {}
	
	for edge in edges:
		for point in edge.points:
			var edges_for_point: Array = point_to_edges.get(point,[])
			edges_for_point.push_back(edge)
			point_to_edges[point] = edges_for_point
			
	var min_heap: MinHeap = MinHeap.new(func (a: Triangle, b: Triangle):
		return a.points[0].distance_to(a.points[1]) - b.points[0].distance_to(b.points[1]))
	
	var already_visited: Dictionary[Vector2, bool] = {}
	var already_visted_edge: Dictionary[String, bool] = {}
	
	min_heap.insert(edges.pick_random())

	var selected_edge: Dictionary[String, Triangle] = {}
	
	while !min_heap.is_empty():
		var visiting_edge: Triangle = min_heap.pop()
		
		if already_visited.has(visiting_edge.points[0]) && already_visited.has(visiting_edge.points[1]):
			continue
	
		selected_edge[visiting_edge.hashcode()] = visiting_edge
		
		if !already_visited.has(visiting_edge.points[0]):
			for edge in point_to_edges.get(visiting_edge.points[0], []):
				if !already_visted_edge.has(edge.hashcode()):
					min_heap.insert(edge)
					already_visted_edge[edge.hashcode()] = true
			already_visited[visiting_edge.points[0]] = true
			
		if !already_visited.has(visiting_edge.points[1]):
			for edge in point_to_edges.get(visiting_edge.points[1], []):
				if !already_visted_edge.has(edge.hashcode()):
					min_heap.insert(edge)
					already_visted_edge[edge.hashcode()] = true

			already_visited[visiting_edge.points[1]] = true
	
	
	var unselected_edges = edges.filter(func (_edge: Triangle):
		return !selected_edge.has(_edge))
		
	var add_back_count = 5
	unselected_edges.shuffle()
	for i in add_back_count:
		var adding_edge = unselected_edges.pop_back()
		selected_edge[adding_edge.hashcode()] = adding_edge
		
	_draw_triangle = selected_edge.values()

	queue_redraw()

func _draw():
	for point in _draw_points:
		draw_circle(point, 5, Color.ALICE_BLUE)
	
	for triangle in _draw_triangle:
		draw_polyline(triangle.points, Color.GREEN)
		
	if _draw_circle:
		draw_circle(_draw_circle.position, _draw_circle.radius, Color.RED, false)

func _on_delaunay_triangulation_circle_drawn(circle: Circle) -> void:
	_draw_circle = circle
	queue_redraw()

func _on_delaunay_triangulation_new_triangles_drawn(triangle: Array[Triangle]) -> void:
	_draw_triangle = triangle
	queue_redraw()


func _on_delaunay_triangulation_point_added(point: Vector2) -> void:
	_draw_points.push_back(point)
	queue_redraw()


func _on_button_pressed() -> void:
	clear()
	run()
