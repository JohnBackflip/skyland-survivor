class_name WarningIndicator
extends Node2D

@export var radius: float = 50.0
@export var base_color: Color = Color(1.0, 0.0, 0.0, 0.3)      # Semi-transparent bright red
@export var shadow_color: Color = Color(0.5, 0.0, 0.0, 0.3)    # Darker red shade for the expanding shadow

var duration: float = 1.0
var shadow_progress: float = 0.0  # Goes from 0.0 (center) to 1.0 (full radius)

func setup(blast_radius: float, wait_time: float) -> void:
	radius = blast_radius
	duration = wait_time
	
	var tween = create_tween().set_parallel(true)

	tween.tween_property(self, "shadow_progress", 1.0, duration)\
		.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_LINEAR)
	
	# Auto-destroy when the warning timer ends
	await get_tree().create_timer(duration).timeout
	queue_free()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	# 1. Draw the base full red circle (the main warning zone)
	draw_circle(Vector2.ZERO, radius, base_color)
	
	# 2. Draw the darker red shadow circle that grows outward from the center
	var current_shadow_radius = radius * shadow_progress
	if current_shadow_radius > 0.0:
		draw_circle(Vector2.ZERO, current_shadow_radius, shadow_color)
