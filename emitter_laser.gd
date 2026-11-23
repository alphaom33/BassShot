extends Node2D

var power: float = 0
var shooting: bool = false
var top_power: float = 10
var dec_speed = 3.0

var low_pitch: float = 0.5
var high_pitch: float = 1.0

var shoot_time: float = 2.0
var max_alpha: float = 2.0
var shoot_alpha: float = 100.0

var player: Node2D
var killies = []

func _ready() -> void:
	player = get_node("/root/Node2D/Plane")

func _process(delta: float):
	for body in killies:
		body.damage(5.0 * delta)
	
	if not shooting:
		power -= delta * dec_speed
		power = max(power, 0.0)
	
		var t = power / top_power
		$Laser.self_modulate.a = lerp(0.0, max_alpha, t)
		$AudioStreamPlayer.pitch_scale = lerp(low_pitch, high_pitch, t)

func shoot():
	if shooting:
		return

	power += 3
	if power >= top_power:
		shooting = true
		$Laser.self_modulate.a = shoot_alpha
		$AudioStreamPlayer.pitch_scale = high_pitch
		$ShootPlayer.play()
		$CollisionShape2D.disabled = false
		player.rotation_speed = 2
		await get_tree().create_timer(shoot_time).timeout
		shooting = false
		$ShootPlayer.stop()
		$CollisionShape2D.disabled = true
		power = 0.0
		player.rotation_speed = 5


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		killies.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Enemy"):
		killies.remove_at(killies.find(body))
