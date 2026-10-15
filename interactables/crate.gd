extends Node2D

@export var sidearm_pool: ItemPool

@onready var popup: PanelContainer = $Popup
@onready var effect_label: Label = $Effect/EffectLabel

const POWERUP_SFX = preload("uid://ofdcxxf5cftr")
const SIDEARM_PICKUP = preload("uid://c0lpw5dgpdalb")

var is_player_nearby: bool = false
var is_opened: bool = false


func _unhandled_input(event: InputEvent) -> void:
	# Check if the player presses 'E', is standing nearby, and the crate is still closed
	if event.is_action_pressed("interact") and is_player_nearby and not is_opened:
		open_crate()
		popup.hide()


func open_crate() -> void:
	print(sidearm_pool.items)
	is_opened = true
	var sidearm = get_sidearm()
	if sidearm:
		var player = get_tree().get_first_node_in_group("player")
		var dropped_sidearm = player.equip_sidearm(sidearm)
		if dropped_sidearm:
			# Spawn a sidearm pickup
			var sidearm_pickup = SIDEARM_PICKUP.instantiate()
			sidearm_pickup.global_position = global_position
			sidearm_pickup.update_data(dropped_sidearm)
			get_tree().current_scene.add_child(sidearm_pickup)
	display_effect(sidearm)
	
	var sfx_player = AudioStreamPlayer2D.new()
	sfx_player.stream = POWERUP_SFX
	add_child(sfx_player)
	sfx_player.play()

	await get_tree().create_timer(2.0).timeout
	queue_free()


func display_effect(sidearm: SidearmData) -> void:
	if sidearm == null:
		effect_label.text = "All out of sidearms!"
	else:
		effect_label.text = "Got a " + sidearm.name + "!"
	effect_label.show()


func get_sidearm() -> SidearmData:
	if sidearm_pool.items.is_empty():
		return null
	var index = randi_range(0, sidearm_pool.items.size() - 1)
	var sidearm = sidearm_pool.items[index]
	sidearm_pool.items.remove_at(index)
	return sidearm


func _on_interaction_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player") and not is_opened:
		popup.show()
		is_player_nearby = true
		

func _on_interaction_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		popup.hide()
		is_player_nearby = false
