extends Sprite2D

const DIRECT_SHOT_PROJECTILE = preload("uid://b54bdytynr87a")
const ARTILLERY_PROJECTILE = preload("uid://dl4wwl4as5p2n")

var sidearm_data: SidearmData


func use(projectile_data: ProjectileData, direction: Vector2, location: Vector2) -> void:
	var projectile
	match sidearm_data.attack_type:
		sidearm_data.AttackType.DIRECT:
			projectile = DIRECT_SHOT_PROJECTILE.instantiate()
			projectile.projectile_data = projectile_data.duplicate()
			projectile.rotation = direction.angle()
			projectile.direction = direction
			projectile.speed = sidearm_data.projectile_speed
			
		sidearm_data.AttackType.ARTILLERY:
			projectile = ARTILLERY_PROJECTILE.instantiate()
			projectile.projectile_data = projectile_data.duplicate()
	
	projectile.damage = sidearm_data.damage
	
	get_tree().current_scene.add_child(projectile)
	projectile.global_position = global_position
	projectile.fire()
