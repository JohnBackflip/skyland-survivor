extends Node
class_name BSPGenerator

@export var map_size: Vector2i
@export var min_room_size: Vector2i
@export var max_rooms: int

@export var fixed_room_size: Vector2i

var grid_data := {}
var rooms: Array[BSPRoom] #Final rooms

@export_category("Tile Map Settings")
@export var tile_map: TileMapLayer
@export var background_tile_index: int
@export var room_tile_index: int
@export var connection_tile_index: int


func _ready() -> void:
	generate()
	shrink_rooms()
	display_rooms()
	connect_rooms()
	

func generate() -> void:
	var root = BSPRoom.new(Rect2i(Vector2i.ZERO, map_size))
	var queue: Array[BSPRoom] = [root]
	while queue.size() > 0 and (queue.size() + rooms.size()) < max_rooms:
		var current_room = queue.pop_front()
		
		# If current room cannot be split anymore, add it to the final rooms. Otherwise, add its children to the queue
		var new_rooms = current_room.split(min_room_size)
		if new_rooms.is_empty():
			rooms.append(current_room)
		else:
			queue += new_rooms
			
	# Add leftover rooms
	rooms += queue
		
func shrink_rooms()	-> void:
	if fixed_room_size.x >= min_room_size.x or fixed_room_size.x <= 0:
		fixed_room_size.x = min_room_size.x - 2
	if fixed_room_size.y >= min_room_size.y or fixed_room_size.y <= 0:
		fixed_room_size.y = min_room_size.y - 2
	
	for bsp_room in rooms:
		var rect: Rect2i = bsp_room.room_info
		var center = rect.get_center()
		var new_x = center.x - (fixed_room_size.x / 2)
		var new_y = center.y - (fixed_room_size.y / 2)
		bsp_room.room_info = Rect2i(Vector2i(new_x, new_y), fixed_room_size)
		

func connect_rooms() -> void:
	rooms.sort_custom(func(a, b): return a.room_info.position.x < b.room_info.position.x)
	for i in range(rooms.size() - 1):
		var room_a_center = rooms[i].room_info.get_center()
		var room_b_center = rooms[i+1].room_info.get_center()
		create_hallway(room_a_center, room_b_center)


func create_hallway(start: Vector2i, end: Vector2i) -> void:
	var current = start
	while current.x != end.x:
		if grid_data[current] == "background":
			tile_map.set_cell(current, connection_tile_index, Vector2i(0,0))
			grid_data[current] = "hallway"
		current.x += 1 if end.x > current.x else -1
	while current.y != end.y:
		if grid_data[current] == "background":
			tile_map.set_cell(current, connection_tile_index, Vector2i(0,0))
			grid_data[current] = "hallway"
		current.y += 1 if end.y > current.y else -1


func display_rooms() -> void:
	tile_map.clear()
	
	# Set background
	for y in range(map_size.y):
		for x in range(map_size.x):
			tile_map.set_cell(Vector2i(x,y), background_tile_index, Vector2i(0,0))
			grid_data[Vector2i(x,y)] = "background"
	
	# Display rooms
	for bsp_room: BSPRoom in rooms:
		var rect: Rect2i = bsp_room.room_info
		# Draw the rooms with a 1-tile padding for walls
		for x in range(rect.position.x + 1, rect.end.x - 1):
			for y in range(rect.position.y + 1, rect.end.y - 1):
				tile_map.set_cell(Vector2i(x, y), room_tile_index, Vector2i(0, 0))
				grid_data[Vector2i(x,y)] = "room"
