extends Control

@onready var damage_number: Label = $DamageNumber

var value: int


func _ready() -> void:
	damage_number.text = str(value)
	
	var tween = create_tween().set_parallel(true)
	#tween.tween_property(self, "global_position:y", global_position.y - 5.0, 0.8).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "modulate:a", 0.0, 0.8)
	
	await tween.finished
	queue_free()
