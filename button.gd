extends Button

func _ready() -> void:
	await pressed
	get_tree().change_scene_to_file("res://main.tscn")
