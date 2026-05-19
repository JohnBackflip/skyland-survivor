extends HBoxContainer

@onready var health_bar: TextureProgressBar = $HealthBar
@onready var health_value_label: Label = $HealthValueLabel

var player


func update_health_bar() -> void:
	if player:
		health_bar.max_value = player.max_health
		health_bar.value = player.current_health
		health_value_label.text = "%d / %d" % [floor(player.current_health), ceil(player.max_health)]
