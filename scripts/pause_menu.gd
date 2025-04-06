extends Control
class_name PauseMenu

@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var background: ColorRect = ColorRect.new()

func  _ready() -> void:
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	background.color = Color(0, 0, 0, 0.5)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(background)
	move_child(background, 0) # Фон под кнопки
	#print("Background added, size: ", background.size, ", visible: ", background.visible)
	print("Background added, visible: ", background.visible) # Должно быть true при show()
	hide() #  Скрыть меню при запуске
	process_mode = PROCESS_MODE_ALWAYS # Обрабатывать меню даже на пузе

func _show_menu() -> void:
	show()
	background.show()
	get_tree().paused = true
	print("Menu shown, background visible: ", background.visible)

func _hide_menu() -> void:
	hide()
	background.hide()
	get_tree().paused = false
	print("Menu hidden, background visible: ", background.visible)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_hide_menu()
		else:
			_show_menu()
	#if event.is_action_pressed("ui_cancel"):
		#if visible:
			#hide()
			#get_tree().paused = false
			#print("Menu hidden, background visible: ", background.visible)
		#else:
			#show()
			#get_tree().paused = true 
			#print("Menu shown, background visible: ", background.visible)

func _on_resume_pressed() -> void:
	_hide_menu()
	#hide()
	#get_tree().paused = false # Снимаем паузу

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().paused = false # Снимаем паузу перед выходом
	get_tree().quit() # Выход из игры
