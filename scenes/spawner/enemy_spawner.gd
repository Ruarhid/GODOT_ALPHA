extends Node2D
class_name EnemySpawner

# Настриваемые параметры
@export var enemy_scenes: Array[PackedScene] = [] # Список сцен врагов
@export var max_enemies: int = 50  # Максимум врагов
@export var wave_interval: float = 5.0 # Интервал между волнами
@export var wave_size: int = 10 # Количество врагов в волне
@export var spawn_interval: float = 1.0  # Интервал спавна внутри волны
@export var min_spawn_distance: float = 100.0 # Минимальное растояние от игрока

# Границы игровой зоны
@export var map_width: float = 1280.0
@export var map_height: float = 720.0
@export var map_offset: Vector2 = Vector2(0, 0)

# Прогресс сложности
@export var wave_size_increase: int = 1 # Увеличение размера волны каждый N волн
@export var wave_interval_decrease: float = 0.5 # Уменьшение интервала каждый N волн
@export var difficulty_step: int = 5 # Каждые 5 волн увеличивать сложность

# Анимация волны
@export var portal_scene: PackedScene = preload("res://scenes/spawner/portal/portal.tscn")

# Ссылки на узлы
@onready var spawn_timer: Timer = %SpawnTimer

# Типы волн
enum WaveType { NORMAL, FAST, MIXED}
var wave_types: Array[Dictionary] = [
	{"type": WaveType.NORMAL, "enemies": [0]}, # Только Mouse(индекс 0 в enemy_scenes
	{"type": WaveType.FAST, "enemies": [1]}, # Только FastMous (индекс 1)
	{"type": WaveType.MIXED, "enemies": [0, 1]} # Смешенная волна
]
# Переменные состояния
var enemy_count: int = 0
var player: Node2D = null  # Ссылка на игрока
var enemies_to_spawn: int = 0 # Сколько врагов осталось спавнить в текущей волне
var wave_count: int = 0 # Счетчик волн
var current_wave_type: Dictionary = {}
var current_portal: Node2D = null

func _ready() -> void:
	randomize()
	player = get_tree().get_first_node_in_group("player")
	if not spawn_timer:
		print("Ошибка: SpawnTimer не найдены!")
		return
	
	spawn_timer.wait_time = wave_interval # Начинаем с паузы перед первой волной
	spawn_timer.timeout.connect(_on_timer_timeout)
	spawn_timer.start()

func _on_timer_timeout() -> void:
	if enemies_to_spawn <= 0:
		# Начинаем новую волну
		wave_count += 1
		update_difficulty()
		select_wave_type()
		enemies_to_spawn = min(wave_size, max_enemies - enemy_count)
		spawn_portal() # Спавн портала перед волной
		print("Волна ", wave_count, " готовится! Тип: ", WaveType.keys()[current_wave_type["type"]], " Врагов: ", enemies_to_spawn)

func spawn_portal() -> void:
	var portal = portal_scene.instantiate()
	portal.global_position = get_random_spawn_position()
	get_parent().add_child(portal)
	current_portal = portal
	portal.spawn_enemies.connect(_on_portal_spawn_enemies)

func _on_portal_spawn_enemies(portal_position: Vector2) -> void:
	# Спавн врагов из позиции портала
	for i in range(enemies_to_spawn):
		_spawn_single_enemy(portal_position)
		await  get_tree().create_timer(spawn_interval).timeout # Задержака между спавнами
	# Удаляем портал после спавна врагов
	if current_portal:
		current_portal.queue_free()
		current_portal = null
		
	enemies_to_spawn = 0
	current_portal = null
	spawn_timer.wait_time = wave_interval # Пауза до следующей волны
	print("Волна: ", wave_count, " завершена")

func _spawn_single_enemy(spawn_pos: Vector2) -> void:
	var enemy_index = current_wave_type["enemies"][randi() % current_wave_type["enemies"].size()]
	var enemy_scene = enemy_scenes[enemy_index]
	var enemy = enemy_scene.instantiate()
	
	# Небольшое случайное смещение от портала
	var offset = Vector2(randf_range(-20, 20), randf_range(-20, 20))
	enemy.global_position = spawn_pos + offset
	get_parent().add_child(enemy)
	enemy_count += 1
	enemy.tree_exited.connect(_on_enemy_defeated)
	print("Враг появился в: ", enemy.global_position)

func get_random_spawn_position() -> Vector2:
	var attempts = 0
	var max_attempts = 10
	var spawn_pos = Vector2.ZERO
	
	while  attempts < max_attempts:
		# Случайная позиция внутри карты
		spawn_pos.x = map_offset.x + randf_range(-map_width / 2, map_width / 2)
		spawn_pos.y = map_offset.y + randf_range(-map_height / 2, map_height / 2)
		if spawn_pos.distance_to(player.global_position) >= min_spawn_distance:
			return spawn_pos
		attempts += 1
	print("Внимание: Не удалось найти позицию подальше от игрока")
	return spawn_pos

func select_wave_type() -> void:
	current_wave_type = wave_types[randi() % wave_types.size()]

func update_difficulty() -> void:
	if wave_count % difficulty_step == 0:
		wave_size += wave_size_increase
		wave_interval = max(wave_interval - wave_interval_decrease, 1.0) # Не меньше 1 секунды
		print("Сложность увеличина! Размер волны: ", wave_size, " Интервал: ", wave_interval) 

func  _on_enemy_defeated() -> void:
	enemy_count -= 1

# Публичные методы для управления спавнером
func  start_spawning() -> void:
	spawn_timer.start()

func stop_spawning() -> void:
	spawn_timer.stop()

func set_spawn_intrval(new_interval: float) -> void:
	spawn_interval = new_interval
