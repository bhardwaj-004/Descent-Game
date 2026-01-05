extends Control

@onready var color_slider = $ColorPickerBox/Slider
@onready var color_preview = $ColorPickerBox/PlayerSprite

func get_color_from_value(value: float) -> Color:
	if value <= 10.0:  # Map the first 10% to black
		var brightness = 1.0 - value / 10.0
		return Color(brightness, brightness, brightness)
	else:  # Map the middle range to hues
		var hue = (value - 10.0) / 80.0
		return Color.from_hsv(hue, 1.0, 1.0)

func _on_slider_value_changed(value: float) -> void:
	var selected_color = get_color_from_value(value)
	color_preview.modulate = selected_color
	PlayerColor.player_color = selected_color
