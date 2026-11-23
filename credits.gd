extends Node2D

var end_y: float = 647

func _ready():
	var i = 0.0
	while i < 1.0:
		await get_tree().process_frame
		i += get_process_delta_time() * 0.5
		$Blacker.modulate.a = 1.0 - i
	
	i = 0.0
	var initial_y = $Plane.position.y
	while i < 1.0:
		await get_tree().process_frame
		i += get_process_delta_time() * 0.4
		$Plane.position.y = lerp(initial_y, end_y, easeInOutBack(i))
		
	$Credits.go = true
		
func easeInOutBack(x: float) -> float:
	var c1 = 1.70158;
	var c2 = c1 * 1.525;

	return ((pow(2 * x, 2) * ((c2 + 1) * 2 * x - c2)) / 2 if x < 0.5
		else (pow(2 * x - 2, 2) * ((c2 + 1) * (x * 2 - 2) + c2) + 2) / 2)
