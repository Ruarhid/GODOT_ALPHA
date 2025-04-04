# main_menu.gd
extends Control

class_name MainMenu

@onready var play_button: Button = %PlayButton as Button
@onready var options_button: Button = %OptionsButton as Button
@onready var about_button: Button = %AboutButton as Button
@onready var exit_button: Button = %ExitButton as Button

var config: GameConfig = Settings

func _ready() -> void:
	_connect_buttons()
	print("Текушая громкость Master: ", config.master_volume)
	print("Текушая громкость Music: ", config.music_volume)
	print("Текушая громкость SFX: ", config.sfx_volume)

func _connect_buttons() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	about_button.pressed.connect(_on_about_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/options_menu.tscn")

func _on_about_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/about.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()
