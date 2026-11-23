extends Sprite2D

@export var multiplier = 0.1

func _process(delta: float):
	position = get_node("/root/Node2D/CameraHolder").position * multiplier + Vector2.UP * 2267.0
