extends Control
class_name PauseMenu

@onready var resume_button: Button = %ResumeButton
@onready var exit_button: Button = %ExitButton
@onready var main_menu_button: Button = %MainMenuButton
@onready var background: ColorRect = %Background

func  _ready() -> void:
	hide()
	resume_button.pressed.connect(_on_resume_pressed)
	main_menu_button.pressed.connect(_on_main_menu_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	background.color = Color(0, 0, 0, 0.5)
	background.set_anchors_preset(Control.PRESET_FULL_RECT)
	process_mode = Node.PROCESS_MODE_ALWAYS # Обрабатывать меню даже на пузе
	print("PauseMenu initialized")

func _show_menu() -> void:
	var upgrade_menu = get_tree().get_first_node_in_group("upgrade_menu")
	if upgrade_menu and upgrade_menu.is_visible():
		upgrade_menu.hide() # Скрыть UpgradeMenu
	show()
	background.show()
	get_tree().paused = true
	print("PauseMenu show, background visible: ", background.visible)

func _hide_menu() -> void:
	hide()
	background.hide()
	get_tree().paused = false
	print("PauseMenu hidden, background visible: ", background.visible)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if visible:
			_hide_menu()
		else:
			_show_menu()

func _on_resume_pressed() -> void:
	_hide_menu()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/main_menu.tscn")

func _on_exit_pressed() -> void:
	get_tree().paused = false # Снимаем паузу перед выходом
	get_tree().quit() # Выход из игры
