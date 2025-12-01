class_name DrunkardsDungeonVisualizer extends Node2D

@export var map_size: Vector2i = Vector2i(1920, 1080)
@export var dungeon_generator: Node
@export var input_mode := true

var map: Array[Array]
var map_img: ImageTexture

var position_queue: Array[Vector2i] = []
var map_queue: Array = []

func _ready():
	map = dungeon_generator.generate(map_size)
	var img := Image.create_empty(map_size.x, map_size.y, false, Image.FORMAT_RGBA8)
	
	for i in map.size():
		for j in map[i].size():
			img.set_pixel(i, j, Color.BLACK)
				
	map_img = ImageTexture.create_from_image(img)
	
func _input(event):
	if event.is_action_pressed("ui_accept"):
		if dungeon_generator is CellularAutomataGenerator && !map_queue.is_empty():
			var map_grid = map_queue.pop_front()
			var new_img = map_img.get_image()
			
			for col in map_grid.size():
				for row in map_grid[col].size():
					if map_grid[col][row] == (dungeon_generator as CellularAutomataGenerator).integer_for_live_cell:
						new_img.set_pixel(col, row, Color.FLORAL_WHITE)
					else:
						new_img.set_pixel(col, row, Color.BLACK)
						
			map_img = ImageTexture.create_from_image(new_img)

			queue_redraw()

func _draw():
	if !map:
		return

	draw_texture_rect(map_img, Rect2(0,0,1920,1080), false)

func _on_update_timer_timeout() -> void:
	if input_mode:
		return
	
	if dungeon_generator is DrunkardsWalkGenerator:
		if position_queue.is_empty():
			return
			
		var new_img = map_img.get_image()

		for i in 10:
			if position_queue.is_empty():
				break
			var carved_position: Vector2i = position_queue.pop_front()
			new_img.set_pixel(carved_position.x, carved_position.y, Color.FLORAL_WHITE)
		
		map_img = ImageTexture.create_from_image(new_img)
		
	elif dungeon_generator is CellularAutomataGenerator && !map_queue.is_empty():
		var map_grid = map_queue.pop_front()
		var new_img = map_img.get_image()
		
		for col in map_grid.size():
			for row in map_grid[col].size():
				if map_grid[col][row] == (dungeon_generator as CellularAutomataGenerator).integer_for_live_cell:
					new_img.set_pixel(col, row, Color.FLORAL_WHITE)
				else:
					new_img.set_pixel(col, row, Color.BLACK)
					
		map_img = ImageTexture.create_from_image(new_img)

	queue_redraw()
		

func _on_drunkards_walk_generator_new_position_carved(pos: Vector2i) -> void:
	position_queue.push_back(pos)

func _on_cellular_automata_generator_generation_done(map: Array[Array]) -> void:
	map_queue.push_back(map)
