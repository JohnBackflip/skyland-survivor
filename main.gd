extends Node2D

@export var map_width: int = 100
@export var map_height: int = 100
@export var enemy_stats: EnemyStats
@export var flying_enemy_stats: FlyingEnemyStats
#@export var difficulty_increase_limit: int = 5

signal game_results(result: String)

const TUTORIAL_SCREEN = preload("uid://bbiqssgt5kfif")

const PLAYER = preload("uid://comnolmmr12ub")
const ENEMY = preload("uid://cjs8832dw81os")
const FLYING_ENEMY = preload("uid://ddphwquiucc5r")

# Example shapes defined by their grid offsets
const SHAPES = {
	"I": [Vector2i(0,0), Vector2i(0,-1), Vector2i(0,1), Vector2i(0,2)],
	"T": [Vector2i(0,0), Vector2i(-1,0), Vector2i(1,0), Vector2i(0,1)],
	"O": [Vector2i(0,0), Vector2i(1,0), Vector2i(0,1), Vector2i(1,1)],
	"L": [Vector2i(0,0), Vector2i(0,-1), Vector2i(0,1), Vector2i(1,1)],
	"L-inverted": [Vector2i(0,0), Vector2i(0,-1), Vector2i(0,1), Vector2i(-1,1)],
	"Z": [Vector2i(0,0), Vector2i(1,0), Vector2i(1,-1), Vector2i(0,1)],
	"Z-inverted": [Vector2i(0,0), Vector2i(-1,0), Vector2i(-1,-1), Vector2i(0,1)]
}

# Explicitly build a typed array from the constant data
var current_shape: Array[Vector2i]

@onready var map_generator: BSPGenerator = $MapGenerator
@onready var preview_layer: TileMapLayer = $PreviewLayer
@onready var health_ui: HBoxContainer = $CanvasLayer/HUD/VBoxContainer/HealthUI
@onready var current_block_display: PanelContainer = $CanvasLayer/HUD/VBoxContainer/CurrentBlockDisplay
@onready var time_left_label: Label = $CanvasLayer/TimeLeftLabel
@onready var win_timer: Timer = $WinTimer

var map_data: Dictionary = {}
var astar := AStarGrid2D.new()
var player: CharacterBody2D
var difficulty_increase_count: int = 0


func _ready() -> void:
	if game_manager.is_first_login:
		show_tutorial()
	
	enemy_stats = enemy_stats.duplicate()
	flying_enemy_stats = flying_enemy_stats.duplicate()
	map_generator.generate_map(map_width, map_height)
	map_data = map_generator.grid_data
	current_shape = get_new_piece()
	current_block_display.display_shape(current_shape)
	spawn_player()
	setup_pathfinding(map_width, map_height)
	
	game_results.connect($CanvasLayer/HUD/GameResults.display_results)
	
	
func _process(_delta: float) -> void:
	var time_left = win_timer.time_left
	var minute = floor(time_left / 60.0)
	var seconds = time_left - minute * 60.0
	time_left_label.text = "%02d:%02d" % [minute, seconds]
	
	preview_layer.clear() # Wipe the previous frame's preview
	
	var mouse_grid_pos = get_mouse_grid_position()
	var is_valid = can_place_shape(mouse_grid_pos, current_shape)
	
	if is_valid:
		# Translucent Green (Red: 0.3, Green: 1.0, Blue: 0.3, Alpha: 0.6)
		preview_layer.modulate = Color(0.3, 1.0, 0.3, 0.3) 
	else:
		# Translucent Red (Red: 1.0, Green: 0.3, Blue: 0.3, Alpha: 0.6)
		preview_layer.modulate = Color(1.0, 0.3, 0.3, 0.3)
	
	for offset in current_shape:
		var preview_pos = mouse_grid_pos + offset
		preview_layer.set_cell(preview_pos, 1, Vector2i(0,0))


func _physics_process(_delta: float) -> void:
	# Check every frame: Is the attack button currently pressed down right now?
	if Input.is_action_pressed("attack"):
		if player:
			player.attack()


func _on_win_timer_timeout() -> void:
	get_tree().paused = true
	game_results.emit("You Win!")


func on_player_death() -> void:
	get_tree().paused = true
	game_results.emit("Game Over")


# Piece Placement

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("place_piece"):
		# 1. Get the tile coordinate under the mouse
		var mouse_grid_pos = get_mouse_grid_position()
		
		# 2. Check if the entire shape fits there
		if can_place_shape(mouse_grid_pos, current_shape):
			place_shape(mouse_grid_pos, current_shape)
		else:
			print("Cannot place here! Overlaps with an island or invalid space.")
	
	if event.is_action_pressed("rotate_piece"):
		rotate_current_shape()


# Converts mouse pixels to grid coordinates based on your TileMap Layer
func get_mouse_grid_position() -> Vector2i:
	var mouse_pos = get_local_mouse_position()
	return $Map.local_to_map(mouse_pos)


# Validation check loop
func can_place_shape(target_pos: Vector2i, shape: Array[Vector2i]) -> bool:
	for offset in shape:
		var check_pos = target_pos + offset
		
		# If the space is a bridge or boundary, placement fails
		if map_data.get(check_pos) == "bridge" or map_data.get(check_pos) == "boundary":
			return false
			
		if map_data.get(check_pos) == "chest":
			return false
			
		# Optional: Ensure they aren't placing it out of bounds/in empty non-existent keys
		if not map_data.has(check_pos):
			return false
			
	return true


func get_new_piece() -> Array[Vector2i]:
	var result: Array[Vector2i]
	var shapes = SHAPES.values()
	var index = randi_range(0, shapes.size() - 1)
	result.assign(shapes[index])
	return result


# Actually updates the grid data and visual map
func place_shape(target_pos: Vector2i, shape: Array[Vector2i]) -> void:
	for offset in shape:
		var final_pos = target_pos + offset
		
		# Update backend data representation
		map_data[final_pos] = "bridge" 
		
		# Update visual TileMapLayer 
		$Map.set_cell(final_pos, 2, Vector2i(0, 0)) 
		update_pathfinding_tile(final_pos, "bridge")
		
	current_shape = get_new_piece()
	current_block_display.display_shape(current_shape)
	
	$BlockPlacementSfxPlayer.play()
	

func rotate_current_shape():
	for i in range(current_shape.size()):
		var coord = current_shape[i]
		current_shape[i] = Vector2i(-coord.y, coord.x)


# Enemy
func _on_difficulty_increase_timer_timeout() -> void:
	difficulty_increase_count += 1
	# Increase stats for previously spawned enemies
	get_tree().call_group("enemy", "increase_stats")
	# Increase stats for future enemies
	enemy_stats.increase_stats()
	if $EnemySpawnTimer.wait_time >= 1.0:
		$EnemySpawnTimer.wait_time -= 0.5
		clampf($EnemySpawnTimer.wait_time, 1.0, 3.0)
	print("Difficulty increased!")
	#if difficulty_increase_count >= difficulty_increase_limit:
		#$DifficultyIncreaseTimer.queue_free()


func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()
	

func _on_flying_enemy_spawn_timer_timeout() -> void:
	spawn_flying_enemy()
	
	
func spawn_flying_enemy() -> void:
	var flying_enemy = FLYING_ENEMY.instantiate() as CharacterBody2D
	flying_enemy.stats = flying_enemy_stats.duplicate()
	
	# Set chunk dimension
	var chunk_pixel_size: float = map_generator.min_room_size.x * 32.0
	var max_dist: float = 2.0 * chunk_pixel_size
	
	# Spawn within 2 chunks of player
	var offset_x = randf_range(-max_dist, max_dist)
	var offset_y = randf_range(-max_dist, max_dist)
	var spawn_position = player.global_position + Vector2(offset_x, offset_y)
	flying_enemy.global_position = spawn_position
	add_child(flying_enemy)


func spawn_enemy() -> void:
	var enemy = ENEMY.instantiate() as CharacterBody2D
	enemy.stats = enemy_stats.duplicate()
	
	# Calculate our chunk boundaries in pixels
	var chunk_pixel_size: float = map_generator.min_room_size.x * 32.0
	var max_dist: float = 2.0 * chunk_pixel_size # Your "2 chunks away" limit
	
	var valid_spawn_found: bool = false
	var enemy_pixel_pos: Vector2 = Vector2.ZERO
	
	# Attempt counter to prevent infinite game freezes
	var attempts: int = 0
	var max_attempts: int = 30
	
	while not valid_spawn_found and attempts < max_attempts:
		attempts += 1
		var island_tile_pos = get_random_island_tile()
		enemy_pixel_pos = Vector2(island_tile_pos) * 32.0
		
		var distance_to_player = enemy_pixel_pos.distance_to(player.global_position)
		
		# CHECK: Is the tile within the 2-chunk boundary circle?
		if distance_to_player <= max_dist:
			valid_spawn_found = true
			
	# Fallback safety: If we failed to find a valid tile within 2 chunks,
	# just use the last generated random tile regardless of distance
	if not valid_spawn_found:
		var fallback_tile = get_random_island_tile()
		enemy_pixel_pos = Vector2(fallback_tile) * 32.0

	# Apply positions and add to tree
	enemy.global_position = enemy_pixel_pos
	add_child(enemy)
	enemy.tilemap_layer = $Map


func setup_pathfinding(width: int, height: int) -> void:
	# 1. Define the grid region matching your world dimensions
	astar.region = Rect2i(0, 0, width, height)
	astar.cell_size = Vector2(32, 32) # Change to match your tile size in pixels
	astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN
	astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER # Force cardinal grid movement
	astar.update()
	
	# 2. Fill the pathfinding map based on your grid_data
	for coords in map_data:
		update_pathfinding_tile(coords, map_data[coords])

# Call this whenever a tile changes (e.g., when building a bridge)
func update_pathfinding_tile(coords: Vector2i, tile_type: String) -> void:
	if tile_type == "island" or tile_type == "bridge":
		# Solid ground is WALKABLE (solid = false)
		astar.set_point_solid(coords, false)
	else:
		# Water/Void blocks movement (solid = true)
		astar.set_point_solid(coords, true)


# Player

func spawn_player() -> void:
	player = PLAYER.instantiate() as CharacterBody2D
	var island_position = get_random_island_tile()
	player.global_position = Vector2(island_position) * 32
	add_child(player)
	health_ui.player = player
	update_health_ui()
	player.health_changed.connect(update_health_ui)
	player.player_died.connect(on_player_death)
	var cam = player.get_node("Camera2D") as Camera2D
	cam.limit_right = map_width * 32
	cam.limit_bottom = map_height * 32


func update_health_ui() -> void:
	health_ui.update_health_bar()


func get_random_island_tile() -> Vector2i:
	var island_tiles = []
	for grid in map_data:
		if map_data[grid] == "island":
			island_tiles.append(grid)
	var index = randi_range(0, island_tiles.size() - 1)
	var island_tile = island_tiles.get(index)
	return Vector2(island_tile)


func show_tutorial() -> void:
	var tutorial = TUTORIAL_SCREEN.instantiate()
	$CanvasLayer.add_child(tutorial)
	game_manager.is_first_login = false
