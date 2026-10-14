extends CharacterBody2D

signal health_changed
signal player_died

const SLASH_EFFECT = preload("uid://df5yak3owdy1k")
const SIDEARM = preload("uid://cb7pw2beikcq")

@onready var i_frame_timer: Timer = $IFrameTimer
@onready var hurtbox: Area2D = $Hurtbox

@export var equipped_sidearm: SidearmData

var max_health := 200.0
var current_health: = max_health
var damage := 10.0
var speed := 150.0
var attack_speed := 1.0

var can_attack: bool = true
var can_use_sidearm: bool = true
var is_invincible: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var attack_cooldown: Timer = $AttackCooldown
@onready var attack_sound_player: AudioStreamPlayer2D = $AttackSoundPlayer
@onready var sidearm_cooldown: Timer = $SidearmCooldown
@onready var sidearm_cooldown_bar: TextureProgressBar = $SidearmCooldownBar


func _physics_process(_delta: float) -> void:
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = direction.normalized() * speed
	if velocity.x > 0:
		sprite_2d.flip_h = false
	elif velocity.x < 0:
		sprite_2d.flip_h = true
	move_and_slide()
	
	if Input.is_action_pressed("attack"):
		attack()
			
	if Input.is_action_pressed("use_sidearm"):
		use_sidearm()


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


func use_sidearm() -> void:
	if not can_use_sidearm:
		return
	var sidearm = SIDEARM.instantiate() as Sprite2D
	sidearm.texture = equipped_sidearm.art
	var direction = global_position.direction_to(get_global_mouse_position())
	sidearm.rotation = direction.angle()
	if direction.x < 0:
		sidearm.flip_v = true
	else:
		sidearm.flip_v = false
	add_child(sidearm)
	
	# Call sidearm usage
	sidearm.sidearm_data = equipped_sidearm.duplicate()
	sidearm.sidearm_data.damage = equipped_sidearm.damage + damage # Add player damage to sidearm
	sidearm.use(equipped_sidearm.projectile_data, direction, get_global_mouse_position())
	
	can_use_sidearm = false
	sidearm_cooldown.start(equipped_sidearm.cooldown)
	display_sidearm_cooldown()
	await get_tree().create_timer(0.5).timeout
	sidearm.queue_free()


func display_sidearm_cooldown() -> void:
	sidearm_cooldown_bar.visible = true
	
	# Reset cd value
	sidearm_cooldown_bar.min_value = 0.0
	sidearm_cooldown_bar.max_value = 100.0
	sidearm_cooldown_bar.value = 100.0

	var tween = create_tween()
	tween.tween_property(sidearm_cooldown_bar, "value", 0, equipped_sidearm.cooldown)
	await tween.finished
	tween.kill()


func take_damage(value: float, bypass_iframe: bool = false) -> void:
	# Reset health regen timer
	#$HealthRegenTimer.start()
	if is_invincible and not bypass_iframe:
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


func _on_sidearm_cooldown_timeout() -> void:
	can_use_sidearm = true
	sidearm_cooldown_bar.visible = false
