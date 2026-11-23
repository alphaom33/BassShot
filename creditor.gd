extends Node2D

var go: bool = false
var speed = 500

func _process(delta: float) -> void:
	if go:
		position.y -= speed * delta
		
		if position.y < -4250.0:
			go = false
			await get_tree().create_timer(1.0).timeout
		
			var i = 0.0
			while i < 1.0:
				await get_tree().process_frame
				i += get_process_delta_time() * 0.5
				get_node("/root/Credits/Blacker").modulate.a = i
		
			await get_tree().create_timer(1.0).timeout
			get_tree().quit()
