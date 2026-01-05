extends Node2D
class_name PlayerView

@onready var shield_material: ShaderMaterial = $AnimatedSprite2D.material as ShaderMaterial
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var player: Player = $".."
@onready var running_particles: CPUParticles2D = $runningParticles
@onready var jumping_particles: CPUParticles2D = $jumpingParticles
@onready var landing_particles: CPUParticles2D = $landingParticles
@onready var jump_sound: AudioStreamPlayer2D = $jumpSound
@onready var death_sound: AudioStreamPlayer2D = $deathSound
var death_flag := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animated_sprite.play("sit")
	running_particles.emitting = false
	jumping_particles.emitting = false
	landing_particles.emitting = false
	jumping_particles.one_shot = true 
	landing_particles.one_shot = true
	player.modulate = PlayerColor.player_color
	shield_material.set("shader_parameter/progress", 0.0)  # Set initial progress to 0.0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if PlayerColor.shield_picked == true:
		shield_material.set("shader_parameter/progress", 1.0)  # Update shader parameter to 1.0
	else:
		shield_material.set("shader_parameter/progress", 0.0)
	if not player.dead:
		# Play animations and effects
		running_particles.emitting = false
		if player.jump:
			animated_sprite.play("jumpFull")
			jump_sound.play()
			jumping_particles.emitting = true
			player.was_on_floor = false
			player.was_in_air = true
		elif player.is_on_floor():
			if player.run_right:
				animated_sprite.play("run")
				animated_sprite.flip_h = false
				running_particles.emitting = true
			elif player.run_left:
				animated_sprite.play("run")
				animated_sprite.flip_h = true
				running_particles.emitting = true
			elif player.idle and player.moved:
				animated_sprite.play("idle")


			# Emit landing particles if the player just landed
			if player.was_in_air:
				landing_particles.emitting = true # Reuse jump particles for landing
				player.was_in_air = false
				jump_sound.play()

			player.was_on_floor = true # Update to reflect that player is on the floor
			# Reset jumping particles to be ready for the next jump
			jumping_particles.emitting = false

		else:
			player.was_on_floor = false
			player.was_in_air = true
			running_particles.emitting = false
		
	elif player.dead and death_flag != 1:
		running_particles.emitting = false
		landing_particles.emitting = false
		jumping_particles.emitting = false
		animated_sprite.play("death")
		death_sound.play()
		death_flag = 1
