extends VBoxContainer

@export var scene : PackedScene
@onready var high_score: Label = $"../HighScore/Score"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	high_score.text = str(HighScore.high_score)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(scene)


func _on_exit_button_3_pressed() -> void:
	get_tree().quit()


func _on_credits_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Credits_page.tscn")


func _on_howtoplay_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/howtoplaymenu.tscn")
