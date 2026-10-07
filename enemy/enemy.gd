extends CharacterBody2D
class_name Enemy

@export var stats: EnemyStats

@onready var world_node = get_parent() # Assuming the parent holds the 'astar' object
@onready var separation_area: Area2D = $SeparationArea

const DAMAGE_EFFECT = preload("uid://c245dyrb0g7wr")

var tilemap_layer: TileMapLayer # Reference to your world's main tile layer
var current_path: Array[Vector2i] = []
var target_pixel_position: Vector2

var current_health: float
var player
var is_touching_player: bool = false

func _ready() -> void:
	var path_timer = Timer.new()
	path_timer.wait_time = randf_range(0.3, 0.5) # Randomize slightly so they don't all calculate on the exact same frame!
	path_timer.autostart = true
	add_child(path_timer)
	path_timer.timeout.connect(_on_path_timer_timeout)
	
	target_pixel_position = global_position
	current_health = stats.max_health
	set_buffer_time()


func _physics_process(_delta: float) -> void:
	move_along_path()
	
	# Continue damaging player if in contact
	if player and is_touching_player:
		player.take_damage(stats.damage)


func _on_path_timer_timeout() -> void:
	player = get_tree().get_first_node_in_group("player")
	if not player:
		return
		
	# 1. Periodically recalculate the path to the player's grid tile
	var enemy_grid_pos = tilemap_layer.local_to_map(global_position)
	var player_grid_pos = tilemap_layer.local_to_map(player.global_position)
	
	# Only calculate if the player moved to a different tile
	if current_path.is_empty() or current_path.back() != player_grid_pos:
		# Request path from our global AStarGrid2D manager
		current_path = world_node.astar.get_id_path(enemy_grid_pos, player_grid_pos)
		
		# The first element is always the tile the enemy is currently standing on
		if not current_path.is_empty():
			current_path.pop_front() 


func move_along_path() -> void:
	# 1. Waypoint advancement check
	if global_position.distance_to(target_pixel_position) < 8.0 and not current_path.is_empty():
		var next_tile = current_path.pop_front()
		target_pixel_position = tilemap_layer.map_to_local(next_tile)
		
	# 2. Base path direction
	var move_direction = global_position.direction_to(target_pixel_position)
	if global_position.distance_to(target_pixel_position) <= 2.0:
		move_direction = Vector2.ZERO

	# 3. Calculate separation from OTHER enemies
	var separation_vector = Vector2.ZERO
	for overlapping_area in separation_area.get_overlapping_areas():
		# Make sure we are only avoiding other enemy separation zones
		if overlapping_area != separation_area:
			# Push directly away from the neighboring enemy
			var push_dir = overlapping_area.global_position.direction_to(global_position)
			# The closer they are, the harder they push away
			var distance = global_position.distance_to(overlapping_area.global_position)
			separation_vector += push_dir * (32.0 / max(distance, 1.0))

	# 4. Blend the path direction with the push away strength
	# (Weight the path movement higher so they don't give up on tracking)
	var final_direction = (move_direction * 1.0 + separation_vector * 0.4).normalized()

	if move_direction != Vector2.ZERO or separation_vector != Vector2.ZERO:
		velocity = final_direction * stats.speed
		move_and_slide()
	else:
		velocity = Vector2.ZERO


func increase_stats() -> void:
	var hp_percentage = current_health / stats.max_health
	stats.increase_stats()
	current_health = stats.max_health * hp_percentage


func take_damage(value: float) -> void:
	current_health -= value
	var damage_effect = DAMAGE_EFFECT.instantiate()
	damage_effect.value = round(value)
	get_parent().add_child(damage_effect)
	damage_effect.global_position = global_position
	var tween = create_tween()
	tween.tween_property($Sprite2D, "self_modulate", Color(1,1,1), 0.3).from(Color(1,0,0))
	if current_health <= 0:
		queue_free()


func set_buffer_time() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	modulate.a = 0.5
	var timer = get_tree().create_timer(2.0)
	await timer.timeout
	process_mode = Node.PROCESS_MODE_INHERIT
	modulate.a = 1.0


func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player") and area.is_in_group("hurtbox"):
		area.get_parent().take_damage(stats.damage)
		is_touching_player = true


func _on_hitbox_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player") and area.is_in_group("hurtbox"):
		is_touching_player = false
