extends Node2D
class_name Level

@onready var pause_menu: PauseMenu = $PauseMenu

func _ready() -> void:
	pause_menu.hide() # Убеждаемся что меню скрыто при старте
	process_mode = PROCESS_MODE_PAUSABLE
	print("Pause Menu type: ", pause_menu.get_class())
		
