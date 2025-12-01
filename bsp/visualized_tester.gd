extends Node2D

@onready var bsp_generator: BSPGenerator = $BSPGenerator
@onready var dungeon_draw_timer: Timer = $DungeonDrawTimer

var dungeon_info: BSPDungeonInfo
var draw_queue: Array[Array] = []
var already_drawn: Dictionary[Rect2, Color] = {}

func _ready():
	dungeon_info = bsp_generator.generate_rooms(Vector2(1920,1080))
	
func _draw():
	for already_drawn_rect in already_drawn.keys():
		draw_rect(already_drawn_rect, already_drawn.get(already_drawn_rect), true)
	
	if draw_queue.is_empty():
		return
	for rect in draw_queue.pop_front() as Array[Rect2]:
		var assigned_color := Color(randf(), randf(), randf())
		draw_rect(rect, assigned_color, true)
		already_drawn[rect] = assigned_color

func _on_bsp_generator_new_split_made(areas: Array[Rect2]) -> void:
	draw_queue.push_back(areas)

func _on_dungeon_draw_timer_timeout() -> void:
	queue_redraw()
