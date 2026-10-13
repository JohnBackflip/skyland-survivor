extends Sprite2D

var projectile_data: ProjectileData
var damage: float
var direction: Vector2
var speed: float = 50.0
var velocity: Vector2


func _physics_process(delta: float) -> void:
	global_position += velocity * delta


func fire() -> void:
	velocity = direction * speed


func _on_hitbox_area_entered(area: Area2D) -> void:
	# Prevent double-triggering if multiple collisions happen in the same frame
	if is_queued_for_deletion():
		return
		
	var enemy = area.get_parent()
	if enemy.is_in_group("enemy") and area.is_in_group("hurtbox"):
		if projectile_data.is_aoe:
			var hit_effect = projectile_data.hit_effect.instantiate()
			hit_effect.damage = damage
			hit_effect.effect_radius = projectile_data.effect_radius
			hit_effect.global_position = global_position
			get_tree().current_scene.call_deferred("add_child", hit_effect)
		else:
			enemy.take_damage(damage)
			
		call_deferred("queue_free")
