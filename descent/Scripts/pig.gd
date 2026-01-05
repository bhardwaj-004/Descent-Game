extends Area2D

@export var speed = 100
@export var patrol_distance = 200
@export var start_right = false
var direction = Vector2(-1, 0)
var starting_position = Vector2.ZERO
@onready var pig_sprite: AnimatedSprite2D = $CollisionShape2D/AnimatedSprite2D

# Called when the node enters the scene
func _ready():
	starting_position = global_position
	pig_sprite.play("run")
	if start_right:
		direction = Vector2(1, 0)

# Called every physics frame
func _physics_process(delta):
	position += direction * speed * delta

	# Check if the enemy has moved beyond the patrol distance
	if global_position.distance_to(starting_position) > patrol_distance:
		# Reverse direction
		direction.x *= -1
		if direction.x != 0:
			self.scale.x = -sign(direction.x)


# Called when another body enters the Area2D
func _on_body_entered(body):
	if body is Player and PlayerColor.shield_picked == false:
		body.dead = true
	elif body is Player and PlayerColor.shield_picked == true:
		PlayerColor.shield_picked = false
