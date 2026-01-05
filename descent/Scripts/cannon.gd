extends StaticBody2D
class_name Cannon

@onready var shot_timer: Timer = $ShotTimer
@export var ShotTime: float = 2.0
@export var face_right := false

var cannon_ball = load("res://Scenes/cannon_ball.tscn") as PackedScene

signal shot_triggered

func _ready() -> void:
	shot_timer.wait_time = ShotTime
	shot_timer.start()
	connect("shot_triggered", Callable(self, "_on_cannon_shoot")) # Corrected connection

func _on_shot_timer_timeout() -> void:
	emit_signal("shot_triggered")

func _on_cannon_shoot() -> void:
	var cannon_ball_instance := cannon_ball.instantiate() as Area2D
	self.add_child(cannon_ball_instance)
