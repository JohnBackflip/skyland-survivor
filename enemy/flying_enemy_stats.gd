extends EnemyStats
class_name FlyingEnemyStats


func increase_stats() -> void:
	max_health *= 1.3
	damage *= 1.3
	speed += 5.0
	speed = clampf(speed, 50.0, 150.0)
	#print("New enemy stats: \n Max Health: %s, Damage: %s, Speed: %s" % [str(max_health), str(damage), str(speed)])
