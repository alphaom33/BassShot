extends Area2D

var speed: float = 600
var lifetime: float = 10.0

func _ready() -> void:
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _process(delta: float) -> void:
	if GlobalState.unfrozen:
		position += Vector2.from_angle(rotation - PI / 2) * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		GlobalState.do_kill()
		queue_free()
