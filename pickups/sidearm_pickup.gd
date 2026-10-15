extends Sprite2D

@onready var popup: PanelContainer = $Popup

var sidearm_data: SidearmData
var is_player_nearby: bool = false


func _enter_tree() -> void:
	var areas = $InteractionArea.get_overlapping_areas()
	print("Overlapping areas: ", areas)
	for area in areas:
		if area.get_parent().is_in_group("player"):
			popup.show()
			is_player_nearby = true


func _unhandled_input(event: InputEvent) -> void:
	# Check if the player presses 'E', is standing nearby, and the crate is still closed
	if event.is_action_pressed("interact") and is_player_nearby:
		pickup_sidearm()
		popup.hide()
		

func pickup_sidearm() -> void:
	var player = get_tree().get_first_node_in_group("player")
	var dropped_sidearm = player.equip_sidearm(sidearm_data)
	update_data(dropped_sidearm)
	

func update_data(new_data: SidearmData) -> void:
	sidearm_data = new_data
	texture = new_data.art


func _on_interaction_area_entered(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		popup.show()
		is_player_nearby = true
		

func _on_interaction_area_exited(area: Area2D) -> void:
	if area.get_parent().is_in_group("player"):
		popup.hide()
		is_player_nearby = false
