extends Control
class_name PauseMenu

@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton

func  _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	hide() # Скрыть меню при запуске
	process_mode = PROCESS_MODE_ALWAYS # Обрабатывать меню даже на пузе

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			hide()
			get_tree().paused = false
		else:
			show()
			get_tree().paused = true
#
func _on_resume_pressed() -> void:
	hide()
	get_tree().paused = false # Снимаем паузу

func _on_exit_pressed() -> void:
	get_tree().paused = false # Снимаем паузу перед выходом
	get_tree().quit() # Выход из игры  \ # get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
