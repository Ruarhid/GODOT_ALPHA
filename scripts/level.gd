extends Node2D
class_name Level

@onready var pause_menu: PauseMenu = $PauseMenu

func _ready() -> void:
	pause_menu.hide() # Убеждаемся что меню скрыто при старте
	process_mode = Node.PROCESS_MODE_PAUSABLE

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # ESC по умолчанию привязан к "ui_cancel"
		if pause_menu.visible: # Если меню уже открыто
			pause_menu.hide()
			get_tree().paused = false # Снимаем с паузы
		else: # Если меню скрыто
			pause_menu.show()
			get_tree().paused = true # Ставим паузу
