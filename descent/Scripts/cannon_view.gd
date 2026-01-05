extends Node2D
class_name CannonView

@onready var cannon: Cannon = $".."
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var cannon_sound: AudioStreamPlayer2D = $CannonShotSound
@onready var shot_timer: Timer = $"../ShotTimer"

func _ready() -> void:
	animated_sprite.play("Idle")
	if cannon.face_right:
		self.scale.x = -1
	cannon.connect("shot_triggered", (Callable(self, "_on_cannon_shot")))

func _on_cannon_shot() -> void:
	animated_sprite.play("Shoot")
	cannon_sound.play()

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite.animation == "Shoot":
		animated_sprite.play("Idle")
