extends Node2D

var speed = 1500
var lifetime = 10.0
var killy = false
var done = false

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float):
	if GlobalState.unfrozen:
		position += Vector2.from_angle(rotation - PI / 2) * speed * delta

func _on_area_2d_body_entered(area: Node2D) -> void:
	if area.is_in_group("Enemy") and not done:
		area.damage(1.0)
		done = true
		queue_free()
	elif area.is_in_group("Player") and killy:
		GlobalState.do_kill()

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Shield"):
		var wall_rotation = area.get_parent().rotation - (PI / 2)
		var adjusted_rot = rotation - wall_rotation
		var rot_vec = Vector2.from_angle(adjusted_rot)
		var rotated_vec = Vector2(rot_vec.x, -rot_vec.y)
		set_deferred("rotation", rotated_vec.angle() + wall_rotation)
		killy = true
