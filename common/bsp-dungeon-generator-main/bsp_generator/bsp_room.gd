extends Resource
class_name BSPRoom

var room_info: Rect2i
var left_child: BSPRoom
var right_child: BSPRoom


func _init(rect: Rect2i) -> void:
	room_info = rect

func split(min_size: Vector2i) -> Array[BSPRoom]:
	if room_info.size.x < 2 * min_size.x and room_info.size.y < 2 * min_size.y:
		return []
		
	var is_split_vertical: bool = randi_range(0,1) == 0
	if room_info.size.x < 2 * min_size.x:
		is_split_vertical = false
	elif room_info.size.y < 2 * min_size.y:
		is_split_vertical = true

	if is_split_vertical:
		var split_x = roundi(randf_range(0.4, 0.6) * room_info.size.x)
		left_child = BSPRoom.new(Rect2i(room_info.position.x, room_info.position.y, split_x, room_info.size.y))
		right_child = BSPRoom.new(Rect2i(room_info.position.x + split_x, room_info.position.y, room_info.size.x - split_x, room_info.size.y))
		return [left_child, right_child]
	else:
		var split_y = roundi(randf_range(0.4, 0.6) * room_info.size.y)
		left_child = BSPRoom.new(Rect2i(room_info.position.x, room_info.position.y, room_info.size.x, split_y))
		right_child = BSPRoom.new(Rect2i(room_info.position.x, room_info.position.y + split_y, room_info.size.x, room_info.size.y - split_y))
		return [left_child, right_child]
