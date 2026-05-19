extends Resource
class_name EnemyStats

@export_group("Base Stats")
@export var max_health: float
@export var damage: float
@export var speed: float = 50.0


func increase_stats() -> void:
	max_health *= 1.5
	damage *= 1.5
	speed += 10.0
	speed = clampf(speed, 50.0, 150.0)
	#print("New enemy stats: \n Max Health: %s, Damage: %s, Speed: %s" % [str(max_health), str(damage), str(speed)])
