extends Node2D

@export var bullet: PackedScene
var num_bullets = 10
var variance = PI / 4

func shoot():
	for _i in range(num_bullets):
		var new_bullet = bullet.instantiate()
		new_bullet.position = global_position
		var scaled = (randf() - 0.5) * 2.0
		new_bullet.rotation = global_rotation + scaled * variance
		get_tree().root.add_child(new_bullet)
	$Shoot.play()
