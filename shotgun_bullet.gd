extends Area2D

var initial_speed = 1500
var speed = initial_speed
var loss = 0.96
var lifetime = 10.0
var killy = false
var going = false

func _ready() -> void:
	speed -= randf() * 100
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float):
	if GlobalState.unfrozen:
		position += Vector2.from_angle(rotation - PI / 2) * speed * delta
		
func _physics_process(delta: float) -> void:
	speed *= loss
	if speed < 500 and not going:
		going = true
		var i = 0.0
		while i < 1.0:
			await get_tree().process_frame
			i += get_process_delta_time()
			$Sprite2D.modulate.a = 1 - i
		queue_free()

func _on_body_entered(area: Node2D) -> void:
	if area.is_in_group("Enemy"):
		area.damage(0.5)
		queue_free()
	elif area.is_in_group("Player") and killy:
		GlobalState.do_kill()

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Shield"):
		var wall_rotation = area.get_parent().rotation - (PI / 2)
		var adjusted_rot = rotation - wall_rotation
		var rot_vec = Vector2.from_angle(adjusted_rot)
		var rotated_vec = Vector2(rot_vec.x, -rot_vec.y)
		set_deferred("rotation", rotated_vec.angle() + wall_rotation)
		killy = true
