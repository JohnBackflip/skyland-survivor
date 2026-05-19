extends Control


func _ready() -> void:
	get_tree().paused = true


func close() -> void:
	get_tree().paused = false
	queue_free()


func _on_button_pressed() -> void:
	close()
