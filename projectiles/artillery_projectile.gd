extends Sprite2D

const WARNING_INDICATOR = preload("uid://dvx5yqssbl4i2")

var projectile_data: ProjectileData
var damage: float
var attack_delay: float
var target_position: Vector2


func _ready() -> void:
	texture = projectile_data.art
	global_position = global_position + Vector2(200.0, -get_viewport_rect().size.y)
	hide()


func fire():
	# Display landing spot
	var indicator = WARNING_INDICATOR.instantiate()
	indicator.global_position = target_position
	get_tree().current_scene.add_child(indicator)
	indicator.setup(projectile_data.effect_radius, attack_delay)
	await get_tree().create_timer(attack_delay).timeout
	
	# Animate projectile to the target spot
	show()
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_position, 0.3)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUAD)
	tween.tween_callback(trigger_hit_effect)
	
	
func trigger_hit_effect() -> void:
	if projectile_data and projectile_data.is_aoe:
		var hit_effect = projectile_data.hit_effect.instantiate()
		hit_effect.damage = damage
		hit_effect.effect_radius = projectile_data.effect_radius
		hit_effect.global_position = target_position
		get_tree().current_scene.add_child(hit_effect)
		print("Meteor target: ", target_position)
		print("Meteor explosion: ", hit_effect.global_position)
		
	call_deferred("queue_free")
