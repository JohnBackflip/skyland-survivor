extends AnimatedSprite2D

@onready var collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D

var damage: float

# Keep a list of enemies this specific slash has already damaged
var targets_hit: Array[Node] = []

func _ready() -> void:
	play()
	# Leave the collision shape enabled in the editor/scene layout!
	await animation_finished
	queue_free()

func _on_hitbox_area_entered(area: Area2D) -> void:
	var enemy = area.get_parent()
	
	if enemy.is_in_group("enemy") and area.is_in_group("hurtbox"):
		# CRITICAL: If we already slashed this specific enemy instance, ignore them!
		if enemy in targets_hit:
			return
			
		# Register the hit
		targets_hit.append(enemy)
		enemy.take_damage(damage)
