extends AnimatedSprite2D

var damage: float
var effect_radius: float = 30.0
var base_texture_radius: float = 16.0 # Half-width of sprite

@onready var collision_shape_2d: CollisionShape2D = $Hitbox/CollisionShape2D


func _ready() -> void:
	var scale_factor = effect_radius / base_texture_radius
	scale = Vector2(scale_factor, scale_factor)
	
	apply_explosion_damage()


func apply_explosion_damage() -> void:
	print("Collision shape radius: ", $Hitbox/CollisionShape2D.shape.radius)
	# Wait 2 physics frames so Area2D populates its overlapping bodies/areas
	await get_tree().physics_frame
	await get_tree().physics_frame

	print("Explosion position: ", global_position)
	print("Explosion damage: ", damage)
	print("Explosion radius: ", effect_radius)
	print("Overlapping areas: ", $Hitbox.get_overlapping_areas())
	
	# Check all hurtboxes caught in the blast radius
	var overlapping_bodies = $Hitbox.get_overlapping_areas()
	print(overlapping_bodies)
	for area in overlapping_bodies:
		var entity = area.get_parent()
		if entity.is_in_group("enemy") and area.is_in_group("hurtbox"):
			entity.take_damage(damage)
		elif entity.is_in_group("player") and area.is_in_group("hurtbox"):
			entity.take_damage(damage, true) # Bypasses iframe


func _on_animation_finished() -> void:
	queue_free()
