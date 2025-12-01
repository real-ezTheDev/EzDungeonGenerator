class_name CellularAutomataGenerator extends Node

signal generation_done(map: Array[Array])

## Initial live cell probability.
@export var initial_percentage := 0.4

## Minimum number of neighboring live cell required to generate a new cell
@export var  min_propagation_count := 2
## Maximum number of neighboring live cell required to generate a new cell
@export var max_propagation_count := 4

## Number of generation iteration the generator would run.
@export var iteration_count := 4

@export var integer_for_live_cell := 1
@export var integer_for_dead_cell := 0

func generate(size := Vector2(50, 50)) -> Array[Array]:
	var map := _intial_spawn(size)
	generation_done.emit(map)
	for i in iteration_count:
		map = next_generation(map)
		generation_done.emit(map)
	return map

## returns 2D array representing the cells in a map (1 is alive, 0 is dead)
func _intial_spawn(size := Vector2(50, 50)) -> Array[Array]:
	var map: Array[Array] = []
	for i in size.x:
		map.push_back([])
		for j in size.y:
			var is_cell_alive := randf() <= initial_percentage
			var cell_value: int = integer_for_live_cell if is_cell_alive else integer_for_dead_cell
			map[i].push_back(cell_value)
	
	return map
	
func next_generation(starting_map: Array[Array]) -> Array[Array]:
	var resulting_map: Array[Array] = []
	for col in starting_map.size():
		var column_array: Array = starting_map[col]
		resulting_map.push_back([])
		for row in column_array.size():
			var current_cell: int = starting_map[col][row]
			
			var neighbor_position_diff: Array[Vector2] = [
				Vector2(+1, 0),
				Vector2(+1, +1),
				Vector2(0, +1),
				Vector2(-1, +1),
				Vector2(-1, 0),
				Vector2(-1, -1),
				Vector2(0, -1),
				Vector2(1, -1)]
			
			var neighbor_count := 0 # count of neighboring live cells
			for neighbor_pos in neighbor_position_diff:
				var neighbor_cell_value: int = integer_for_dead_cell
				if col + neighbor_pos.x >= 0 && col + neighbor_pos.x < starting_map.size() \
					&& row + neighbor_pos.y >= 0 && row + neighbor_pos.y < column_array.size():
					neighbor_cell_value = starting_map[col + neighbor_pos.x][row + neighbor_pos.y]
					
				if neighbor_cell_value == integer_for_live_cell:
					neighbor_count += 1
			
			var resulting_cell_value :int = integer_for_dead_cell
			if neighbor_count >= min_propagation_count && neighbor_count <= max_propagation_count:
				resulting_cell_value = integer_for_live_cell
				
			
			resulting_map[col].push_back(resulting_cell_value)

	return resulting_map
