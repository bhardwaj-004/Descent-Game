extends Area2D
class_name CannonBall

@export var speed: float = -200
var offset := -10

func _ready() -> void:
	var cannon = get_parent() as Cannon
	if cannon:
		var level = cannon.get_parent()
		if level.scale.x == -1:
			offset = 10
		if cannon.face_right:
			offset *= -1
			speed *= -1
		
		global_position = cannon.global_position + Vector2(offset, 0)
		
func _process(delta: float) -> void:
	position.x += speed * delta
	
func _on_body_entered(body: Node2D) -> void:
	queue_free()
	if body is Player and PlayerColor.shield_picked == false:
		body.dead = true
	elif body is Player and PlayerColor.shield_picked == true:
		PlayerColor.shield_picked = false
