extends Node2D
class_name Spikes

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and PlayerColor.shield_picked == false:
		body.dead = true
	elif body is Player and PlayerColor.shield_picked == true:
		PlayerColor.shield_picked = false
