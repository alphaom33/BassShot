extends Sprite2D

var stick_pos: float = 0
var tail_size = 600.0
@export var camera: Node2D

func _process(delta: float):
	if abs(camera.position.y - stick_pos) < tail_size:
		global_position.y = stick_pos
	else:
		position.y = -sign(camera.position.y - stick_pos) * tail_size
