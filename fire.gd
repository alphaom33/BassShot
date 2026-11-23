extends Sprite2D

var count = 0

func _process(delta: float) -> void:
	count += delta
	if count >= 0.05:
		scale.x *= -1
		count = 0
