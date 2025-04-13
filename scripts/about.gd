# about.gd
extends Control

class_name About

@onready var close_button: Button = %CloseButton

func _ready() -> void:
	_connect_signal()

func _connect_signal() -> void:
	close_button.pressed.connect(_on_close_pressed)

func _on_close_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")
