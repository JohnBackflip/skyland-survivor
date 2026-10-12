extends Node

enum DifficultyLevel {EASY, MEDIUM, HARD}

var is_first_login: bool = true
var target_scene_path: String

var difficulty: DifficultyLevel = DifficultyLevel.MEDIUM

const LOADING_SCREEN_PATH = "res://common/LoadingScreen/loading_screen.tscn"


func load_scene(path: String):
	target_scene_path = path
	var loading_screen = load(LOADING_SCREEN_PATH)
	get_tree().change_scene_to_packed(loading_screen)
