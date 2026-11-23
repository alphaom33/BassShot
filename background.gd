extends Sprite2D

@export var speed = 1000

func _process(delta: float) -> void:
	position.y += speed * delta
	if position.y >= 945:
		position.y = -945
