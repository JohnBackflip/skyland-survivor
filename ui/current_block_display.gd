extends PanelContainer

const BRIDGE_TILE = preload("uid://cl4ykwit7nif8")

@onready var grid_container: GridContainer = $GridContainer

func _ready() -> void:
	grid_container.columns = 5
	# Fill the 4x4 grid with 16 empty texture slots
	for i in range(25):
		var tr = TextureRect.new()
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		tr.size_flags_vertical = Control.SIZE_EXPAND_FILL
		grid_container.add_child(tr)

func display_shape(shape: Array[Vector2i]) -> void:
	# 1. Clear all slots first
	for child in grid_container.get_children():
		child.texture = null
		
	# 2. Map our offsets into a 4x4 matrix slot index
	# Assuming (0,0) anchors around grid slot column 1, row 1
	for offset in shape:
		var local_grid_x = 2 + offset.x
		var local_grid_y = 2 + offset.y
		
		# Keep it within bounds of our 4x4 UI box
		if local_grid_x >= 0 and local_grid_x < 5 and local_grid_y >= 0 and local_grid_y < 5:
			var slot_index = (local_grid_y * 5) + local_grid_x
			grid_container.get_child(slot_index).texture = BRIDGE_TILE
