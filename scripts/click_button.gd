# click_button.gd
extends Button

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	AudioManager.play_click_sound()
