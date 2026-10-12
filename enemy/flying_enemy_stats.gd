extends EnemyStats
class_name FlyingEnemyStats


func increase_stats(difficulty) -> void:
	var stats_scaling: float = 1.05
	var speed_scaling: float = 20.0
	
	match difficulty:
		game_manager.DifficultyLevel.EASY:
			stats_scaling = 1.2
		game_manager.DifficultyLevel.MEDIUM:
			stats_scaling = 1.3
		game_manager.DifficultyLevel.HARD:
			stats_scaling = 1.4
	
	max_health *= stats_scaling
	damage *= stats_scaling
	speed += speed_scaling
	speed = clampf(speed, 50.0, 150.0)
	#print("New enemy stats: \n Max Health: %s, Damage: %s, Speed: %s" % [str(max_health), str(damage), str(speed)])
