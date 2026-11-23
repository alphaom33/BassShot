extends Node2D

@export var bullet: PackedScene

func shoot():
	var new_bullet = bullet.instantiate()
	new_bullet.position = global_position
	new_bullet.rotation = global_rotation
	get_tree().root.add_child(new_bullet)
	$Shoot.play()
