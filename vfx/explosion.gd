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
	# Wait one physics frame so Area2D populates its overlapping bodies/areas
	await get_tree().physics_frame
	
	# Check all bodies or hurtboxes caught in the blast radius
	var overlapping_bodies = $Hitbox.get_overlapping_areas()
	for area in overlapping_bodies:
		var enemy = area.get_parent()
		if enemy.is_in_group("enemy") and area.is_in_group("hurtbox"):
			enemy.take_damage(damage)


func _on_animation_finished() -> void:
	queue_free()
