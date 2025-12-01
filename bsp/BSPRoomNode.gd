class_name BSPRoomNode extends Resource

@export var room_info: Rect2
@export var sub_division: Array[BSPRoomNode]

func _init(_room_info: Rect2):
	room_info = _room_info
	sub_division = []
	
