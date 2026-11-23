extends Sprite2D

func _ready():
	frame = 0
	$Plane.visible = true
	for i in range(8):
		await get_tree().create_timer(0.1).timeout
		frame += 1
		if frame == 4:
			$Plane.visible = false
