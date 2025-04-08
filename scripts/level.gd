extends Node2D
class_name Level

@onready var pause_menu: PauseMenu = $PauseUI/PauseMenu
@onready var enemy_spawner: EnemySpawner = $EnemySpawner

func _ready() -> void:
	pause_menu.hide()  # Убеждаемся, что меню скрыто при старте
	process_mode = PROCESS_MODE_PAUSABLE
	enemy_spawner.enemy_scenes = [
		preload("res://scenes/mobs/mouse/mouse.tscn"),
		preload("res://scenes/mobs/fast_mouse/fast_mouse.tscn")
	]
	enemy_spawner.start_spawning() # Запуск спавна
	print("Pause Menu type: ", pause_menu.get_class())
