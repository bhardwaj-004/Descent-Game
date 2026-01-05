extends Node
class_name Game

@onready var player: Player = $Player
@onready var game_start_timer: Timer = $GameStart
@onready var endless_level: Node2D = $Endless
@onready var score: Label = $"../HUD/Score"
@onready var parallax: Node2D = $"../parallax"
@onready var camera: Camera2D = $"../Camera2D"
@onready var death_menu: Control = $"../Camera2D/Deathmenu"
@onready var pause_menu: Control = $"../Camera2D/PauseMenu"
@onready var bottom_border: CollisionShape2D = $Killzone/BottomBorder
@onready var top_border: CollisionShape2D = $Killzone/TopBorder
@onready var high_score: Label = $"../HUD/HighScore/HighScore2"

const GRAVITY := 800
const FRICTION := 1500
const SPEED := 150
const JUMP_VELOCITY := -265
const delete_sceneY := -1000
const add_sceneY := 2000
const RESET_THRESHOLD := 1000 # prevent overflow
const player_size := 16

var camera_top_y : float
var scroll_speed : float
var is_scrolling := false
var max_score := 0
var temp_score := 0

# Scenes
var start_scene = load("res://Scenes/levels/level_1.tscn") as PackedScene
const SCENES := [
	"res://Scenes/levels/level_2.tscn",
	"res://Scenes/levels/level_9.tscn",
	"res://Scenes/levels/level_10.tscn",
	"res://Scenes/levels/level_11.tscn",
	"res://Scenes/levels/level_12.tscn",
	"res://Scenes/levels/level_13.tscn",
	"res://Scenes/levels/level_14.tscn",
	"res://Scenes/levels/level_7.tscn",
	"res://Scenes/levels/level_6.tscn",
	"res://Scenes/levels/level_8.tscn"
	# Levels need collision fixes, and moving platforms
	#"res://Scenes/levels/level_3.tscn",
	#"res://Scenes/levels/level_4.tscn",
	#"res://Scenes/levels/level_5.tscn"
]
var active_scenes: Array = []
var previous_tile_map_end_height : int
var top_segment : Node2D
var prev_top : Node2D
var top_segment_end_height : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("HIGH SCORE:", HighScore.high_score)
	death_menu.hide()
	game_start_timer.start()
	var start_level = start_scene.instantiate()
	endless_level.add_child(start_level)
	active_scenes.append(start_level)
	top_segment = active_scenes[0]
	var level1_size = get_level_size(top_segment)
	top_segment_end_height = level1_size[1]
	camera_top_y = camera.position.y - (camera.get_viewport_rect().size.y / 2) / camera.zoom.y
	calc_high_score()
	
func _physics_process(delta: float) -> void:
	if not player.dead:
		_tick_game(delta)
	elif player.dead:
		game_over(delta)

func _tick_game(delta: float) -> void:
	if is_scrolling:
		# scroll speed increases proportional to score
		scroll_speed = 50 + max_score * 0.4
		if scroll_speed > 150:
			scroll_speed = 150
		camera.position.y += scroll_speed * delta
		bottom_border.position.y = camera.position.y - camera_top_y + player_size
		top_border.position.y = camera.position.y + camera_top_y - player_size
		
	# Check if the endless_level Y position has crossed the threshold
	# Currently this messes with the parallax behaviour so leaving out
	#if camera.position.y > RESET_THRESHOLD:
		#reset_positions()
			
	# Add a new segment on the bottom
	if active_scenes.size() != 0:
		var last_segment = active_scenes[active_scenes.size() - 1]
		if last_segment.position.y + previous_tile_map_end_height < add_sceneY + camera.position.y:
			spawn_new_segment()
			print(active_scenes)

	if top_segment and (top_segment.global_position.y + top_segment_end_height < camera.position.y - camera_top_y + delete_sceneY):
		remove_top_segment()
		
	# Score
	calculate_score(temp_score)
	
	update_movement(delta)
	
	#cannons_shoot(delta)

func update_movement(delta : float):
	player.idle = false
	player.run_right = false
	player.run_left = false
	player.jump = false
	
	if Input.is_action_just_pressed("jump") and player.is_on_floor():
		player.jump = true
		player.moved = true
	if Input.is_action_pressed("right"):
		player.run_right = true
		player.moved = true
	if Input.is_action_pressed("left"):
		player.run_left = true
		player.moved = true
	
	# movement for character
	if player.run_right:
		player.velocity.x = SPEED
	elif player.run_left:
		player.velocity.x = -SPEED
	else:
		player.idle = true
		# Apply friction when not moving
		if player.velocity.x != 0:
			var friction_amount = FRICTION * delta
			if abs(player.velocity.x) < friction_amount:
				player.velocity.x = 0
			else:
				player.velocity.x -= sign(player.velocity.x) * friction_amount

	# Gravity
	if not player.is_on_floor():
		player.velocity.y += GRAVITY * delta
	# Jumping
	if player.jump:
		player.velocity.y = JUMP_VELOCITY

	player.move_and_slide()
	
func calculate_score(prev_score : int):
	var descent := player.position.y
	var current_score := (int(descent / 20) + prev_score)
	prev_score = 0
	# Update max_score only if the current score is greater
	if current_score > max_score:
		max_score = current_score
	score.text = str(max_score)

func calc_high_score():
	var current_score = int(score.text)
	if HighScore.high_score <= current_score:
		HighScore.high_score = current_score
		high_score.text = str(HighScore.high_score)
	elif int(high_score.text) != HighScore.high_score:
		high_score.text = str(HighScore.high_score)

func game_over(delta: float) -> void:
	is_scrolling = false
	calc_high_score()
	death_menu.show()
	# Only apply gravity to player while everything else is paused
	player.velocity.y += GRAVITY * delta
	player.move_and_slide()
	if player.is_on_floor():
		player.velocity = Vector2.ZERO
		print("You DIED")
		get_tree().paused = true

func _on_killzone_body_entered(_body: Node2D) -> void:
	player.dead = true
	PlayerColor.shield_picked = false
	
func _on_game_start_timeout() -> void:
	is_scrolling = true

func spawn_new_segment():
	# Choose a random scene path and instance it
	var scene_path = SCENES[randi() % SCENES.size()]
	var segment : Node2D = load(scene_path).instantiate()

	# Position the segment at the bottom of the previous level
	var previous_segment : Node2D = active_scenes[active_scenes.size() - 1]
	var level_size : Array = get_level_size(previous_segment)
	if level_size != [0,0]:
		var previous_tile_map_start_height = level_size[0]
		previous_tile_map_end_height = level_size[1]
		segment.position = previous_segment.position + Vector2(0, previous_tile_map_end_height + previous_tile_map_start_height)
		# Chance to mirror the level
		if randf() < 0.5:
			segment.scale.x = -1 
			print("Level Mirrored:  ", segment.name)
		# Add to the scene tree and track it in active_scenes
		endless_level.add_child(segment)
		active_scenes.append(segment)
	else:
		print("ERROR: level_size returned [0,0]")

func get_level_size(level: Node2D) -> Array:
	var tilemap := level.get_node("Building")
	if tilemap:
		# Calculate the dimensions of the Building TileMapLayer
		var used_rect : Rect2i = tilemap.get_used_rect()
		# Start and end height position of the level
		var starting_height = used_rect.position.y
		var ending_height = used_rect.size.y
		# Size of the tiles in the tilemaplayer
		var tile_size : Vector2i = tilemap.tile_set.get_tile_size()
		var start_height_in_pixels : int = starting_height * tile_size.y
		var end_height_in_pixels : int = ending_height * tile_size.y
		return [start_height_in_pixels, end_height_in_pixels]
	else:
		print("Building TileMapLayer not found.")
		return [0,0]

func remove_top_segment():
	if active_scenes.size() > 0:
		# Remove the current top segment
		top_segment.queue_free()
		active_scenes.remove_at(0)
		print("Top Segment Removed")

		# Update the new top segment, if any
		if active_scenes.size() > 0:
			top_segment = active_scenes[0]
			var top_segment_size = get_level_size(top_segment)
			top_segment_end_height = top_segment_size[1]
		else:
			top_segment = null
			print("Top segment removed.")


func reset_positions():
	var offset := camera.position.y
	temp_score = max_score
	camera.position.y = 0
	player.position.y -= offset
	# Shift all active segments to maintain their relative positions
	for segment in active_scenes:
		segment.position.y -= offset
