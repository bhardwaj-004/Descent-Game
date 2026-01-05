extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body is Player and PlayerColor.shield_picked == false:
		PlayerColor.shield_picked = true
	queue_free()
