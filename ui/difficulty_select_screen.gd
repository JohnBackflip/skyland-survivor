extends Control

const MAIN = "res://main.tscn"
const MAIN_MENU = "res://ui/main_menu.tscn"


func _on_easy_button_pressed() -> void:
	game_manager.difficulty = game_manager.DifficultyLevel.EASY
	game_manager.load_scene(MAIN)


func _on_medium_button_pressed() -> void:
	game_manager.difficulty = game_manager.DifficultyLevel.MEDIUM
	game_manager.load_scene(MAIN)


func _on_hard_button_pressed() -> void:
	game_manager.difficulty = game_manager.DifficultyLevel.HARD
	game_manager.load_scene(MAIN)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU)
