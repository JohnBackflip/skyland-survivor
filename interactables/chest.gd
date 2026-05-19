extends Node2D

@export var powerup_pool: Array[PowerUp]

@onready var popup: PanelContainer = $Popup
@onready var effect_label: Label = $Effect/EffectLabel

const POWERUP_SFX = preload("uid://ofdcxxf5cftr")

var is_player_nearby: bool = false
var is_opened: bool = false


func _unhandled_input(event: InputEvent) -> void:
	# Check if the player presses 'E', is standing nearby, and the chest is still closed
	if event.is_action_pressed("interact") and is_player_nearby and not is_opened:
		open_chest()
		popup.hide()


func open_chest() -> void:
	is_opened = true
	var powerup = get_powerup()
	var player = get_tree().get_first_node_in_group("player")
	powerup.boost_stat(player)
	display_effect(powerup)
	
	var sfx_player = AudioStreamPlayer2D.new()
	sfx_player.stream = POWERUP_SFX
	add_child(sfx_player)
	sfx_player.play()
	
	var timer = get_tree().create_timer(2.0)
	await timer.timeout
	queue_free()


func display_effect(powerup: PowerUp) -> void:
	if powerup.stat == powerup.Stat.HEALTH:
		effect_label.text = "Health Boosted!"
	elif powerup.stat == powerup.Stat.DAMAGE:
		effect_label.text = "Damage Boosted!"
	elif powerup.stat == powerup.Stat.ATTACK_SPEED:
		effect_label.text = "Attack Speed Boosted!"
	effect_label.show()


func get_powerup() -> PowerUp:
	var index = randi_range(0, powerup_pool.size() - 1)
	return powerup_pool[index]


func _on_interaction_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player") and not is_opened:
		popup.show()
		is_player_nearby = true
		

func _on_interaction_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		popup.hide()
		is_player_nearby = false
