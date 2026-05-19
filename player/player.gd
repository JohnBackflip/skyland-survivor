extends CharacterBody2D

signal health_changed
signal player_died

const SLASH_EFFECT = preload("uid://df5yak3owdy1k")

@onready var i_frame_timer: Timer = $IFrameTimer
@onready var hurtbox: Area2D = $Hurtbox

var max_health := 200.0
var current_health: = max_health
var damage := 10.0
var speed := 150.0
var attack_speed := 1.0

var can_attack: bool = true
var is_invincible: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_sound_player: AudioStreamPlayer2D = $AttackSoundPlayer


func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction.normalized() * speed
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true
	move_and_slide()


func attack() -> void:
	if not can_attack:
		return
	var slash = SLASH_EFFECT.instantiate() as AnimatedSprite2D
	attack_sound_player.play()
	slash.damage = damage
	var mouse_pos = get_global_mouse_position()
	var direction = global_position.direction_to(mouse_pos)
	slash.position = direction * 40.0
	slash.rotation = direction.angle()
	add_child(slash)
	can_attack = false
	attack_cooldown.start(1.0 / attack_speed)
	

func take_damage(value: float) -> void:
	# Reset health regen timer
	#$HealthRegenTimer.start()
	if is_invincible:
		return
	current_health -= value
	current_health = clampf(current_health, 0.0, max_health)
	health_changed.emit()
	start_invincibility()
	var tween = create_tween()
	tween.tween_property(sprite_2d, "self_modulate", Color(1,1,1), 0.3).from(Color(1,0,0))
	if current_health <= 0:
		die()


func start_invincibility() -> void:
	is_invincible = true
	i_frame_timer.start(1.0) # 1 second of safety
	
	# Visual feedback: Make the player blink
	var tween = create_tween().set_loops(4)
	tween.tween_property($Sprite2D, "modulate:a", 0.5, 0.1)
	tween.tween_property($Sprite2D, "modulate:a", 1.0, 0.1)


func _on_i_frame_timer_timeout() -> void:
	is_invincible = false


func die() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	sprite_2d.rotate(deg_to_rad(90.0))
	player_died.emit()


func _on_attack_cooldown_timeout() -> void:
	can_attack = true


func _on_health_regen_timer_timeout() -> void:
	if current_health < max_health:
		current_health += max_health * (5.0 / 100.0)
		current_health = clampf(current_health, 0.0, max_health)
		health_changed.emit()
