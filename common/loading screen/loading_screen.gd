extends Control

var scene_path: String
var progress := []
var scene_load_status: int = 0

@onready var progress_bar: ProgressBar = $ProgressBar


func _ready() -> void:
	scene_path = game_manager.target_scene_path
	ResourceLoader.load_threaded_request(scene_path)
	

func _process(_delta: float) -> void:
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		return
	scene_load_status = ResourceLoader.load_threaded_get_status(scene_path, progress)
	progress_bar.value = progress[0] * 100
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var target_scene = ResourceLoader.load_threaded_get(scene_path)
		await get_tree().create_timer(0.5).timeout
		get_tree().change_scene_to_packed(target_scene)
