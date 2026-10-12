extends Control

const DIFFICULTY_SELECT_SCREEN = "res://ui/difficulty_select_screen.tscn"


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(DIFFICULTY_SELECT_SCREEN)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
