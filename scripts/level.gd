extends Node2D
class_name Level

@onready var pause_menu: PauseMenu = $PauseMenu

# Загружаем сцену мыши
const MOUSE_SCENE = preload("res://scenes/enemies/mouse/Mouse.tscn")

# Размеры области спавна (настройте под вашу карту)
const SPAWN_AREA_WIDTH = 1152.0  # Примерно размер экрана по горизонтали
const SPAWN_AREA_HEIGHT = 648.0  # Примерно размер экрана по вертикали

func _ready() -> void:
	pause_menu.hide()  # Убеждаемся, что меню скрыто при старте
	process_mode = PROCESS_MODE_PAUSABLE
	print("Pause Menu type: ", pause_menu.get_class())
	
	# Настраиваем таймер
	$SpawnTimer.connect("timeout", _on_spawn_timer_timeout)

func _on_spawn_timer_timeout():
	# Спавним мышь
	spawn_mouse()

func spawn_mouse():
	# Создаём экземпляр мыши
	var mouse = MOUSE_SCENE.instantiate()
	
	# Генерируем случайную позицию
	var spawn_x = randf_range(-SPAWN_AREA_WIDTH / 2, SPAWN_AREA_WIDTH / 2)
	var spawn_y = randf_range(-SPAWN_AREA_HEIGHT / 2, SPAWN_AREA_HEIGHT / 2)
	mouse.position = Vector2(spawn_x, spawn_y)
	
	# Добавляем мышь в сцену
	add_child(mouse)
	
	# Отладка
	print("Spawned mouse at: ", mouse.position)
