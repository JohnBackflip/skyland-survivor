extends Enemy


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	current_health = stats.max_health

func _physics_process(_delta: float) -> void:
	move_towards_player()
	
	# Continue damaging player if in contact
	if player and is_touching_player:
		player.take_damage(stats.damage)

func move_towards_player() -> void:
	if not player:
		return
	
	var direction = (player.global_position - global_position).normalized()
	velocity = direction * stats.speed
	move_and_slide()
