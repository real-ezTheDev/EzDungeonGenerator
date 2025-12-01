class_name DrunkardsWalkGenerator extends Node

signal new_position_carved(pos: Vector2i)

@export var spawn_count: int = 1
@export var minimum_steps: int = 100

var drunkards: Array[Vector2i] = []

func generate(size: Vector2i) -> Array[Array]:
	var map: Array[Array] = []
	for i in size.x:
		map.push_back([])
		for j in size.y:
			map[i].push_back(1)
				
	for count in spawn_count:
		drunkards.push_back(spawn(size))
	
	# carve out the initial spawn position
	carve_out(map)
	
	#crawl and carve for number of steps defined.
	for step in minimum_steps:
		crawl(size)
		carve_out(map)

	return map
	
func carve_out(map: Array[Array]):
	for drunkard in drunkards:	
		map[drunkard.x][drunkard.y] = 0
		new_position_carved.emit(drunkard)

## When called each drunkard's take one step
func crawl(size: Vector2i):
	var updated_drunkards: Array[Vector2i] = []
	
	for drunkard in drunkards:
		var possible_directions: Array[Vector2i] = []
		if drunkard.x > 0: 
			possible_directions.push_back(Vector2i(-1, 0))
			
		if drunkard.x < size.x - 1:
			possible_directions.push_back(Vector2i(1, 0))
			
		if drunkard.y > 0: 
			possible_directions.push_back(Vector2i(0, -1))
			
		if drunkard.y < size.y - 1:
			possible_directions.push_back(Vector2i(0, 1))
			
		var walk_direction: Vector2i = possible_directions.pick_random()
		updated_drunkards.push_back((drunkard as Vector2i) + walk_direction)
		
	drunkards = updated_drunkards

## Spawn a drunkard in a random spot in the grid map.
## Returns the position in the map of the spawned drunkard.
func spawn(size: Vector2i) -> Vector2i:
	var resulting_position :Vector2i = Vector2i(randi_range(0, size.x - 1), randi_range(0, size.y - 1))
	return resulting_position
