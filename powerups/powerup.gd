extends Resource
class_name PowerUp

enum Stat {HEALTH, ATTACK_SPEED, DAMAGE}

@export var stat: Stat


func boost_stat(player) -> void:
	if player:
		if stat == Stat.HEALTH:
			var hp_percentage = player.current_health / player.max_health
			player.max_health += 100.0
			player.current_health = player.max_health * hp_percentage
			player.health_changed.emit()
		elif stat == Stat.DAMAGE:
			player.damage += 5.0
		elif stat == Stat.ATTACK_SPEED:
			player.attack_speed += 0.3
