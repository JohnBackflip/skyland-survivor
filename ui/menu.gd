extends Control

const MAIN_MENU = preload("uid://u3b5qa8ihq5o")


func _ready() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_menu()


func toggle_menu() -> void:
	visible = !visible
	get_tree().paused = visible


func _on_yes_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_packed(MAIN_MENU)


func _on_no_button_pressed() -> void:
	get_tree().paused = false
	hide()
