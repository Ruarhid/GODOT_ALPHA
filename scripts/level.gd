extends Node2D
class_name Level

@onready var pause_menu: PauseMenu = $PauseUI/PauseMenu
@onready var enemy_spawner: EnemySpawner = $EnemySpawner
@onready var upgrade_menu: UpgradeMenu = $Player/UI/UpgradeMenu

func _ready() -> void:
	pause_menu.hide()  # Убеждаемся, что меню скрыто при старте
	upgrade_menu.hide()
	process_mode = PROCESS_MODE_PAUSABLE
	enemy_spawner.enemy_scenes = [
		preload("res://scenes/mobs/mouse/mouse.tscn"),
		preload("res://scenes/mobs/fast_mouse/fast_mouse.tscn")
	]
	enemy_spawner.start_spawning() # Запуск спавна
	print("Pause Menu type: ", pause_menu.get_class())
	print("Upgrade Menu type: ", upgrade_menu.get_class())

func _process(delta: float) -> void:
	if upgrade_menu.visible and not get_tree().paused:
		print("Warning: UpgradeMenu visible while game unpaused! Visible state: ", upgrade_menu.visible)
