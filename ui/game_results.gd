extends Control

@onready var game_result_label: Label = $GameResultLabel

const MAIN_MENU = "res://ui/main_menu.tscn"


func _ready() -> void:
	hide()
	

func display_results(result: String) -> void:
	game_result_label.text = result
	show()


func _on_restart_button_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_return_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU)
