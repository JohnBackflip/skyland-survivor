extends Control

const MAIN = "res://main.tscn"


func _on_start_button_pressed() -> void:
	game_manager.load_scene(MAIN)


func _on_quit_button_pressed() -> void:
	get_tree().quit()
