extends VBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible=false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			_resume_game()
		else:
			_pause_game()


func _pause_game()->void:
	get_tree().paused=true
	visible=true
	
func _resume_game()->void:
	get_tree().paused=false
	visible=false
	
func _on_exit_button_3_pressed() -> void:
	get_tree().quit()


func _on_resume_button_pressed() -> void:
	_resume_game()

func _on_restart_button_2_pressed() -> void:
	get_tree().paused=false
	get_tree().reload_current_scene()
	
func _on_mainmenu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")
