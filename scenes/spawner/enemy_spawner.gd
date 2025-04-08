extends Node2D
class_name EnemySpawner

@export var enemy_scenes: Array[PackedScene] = [] # Список сцен врагов
@export var spawn_zones: Array[Vector2] = [] # Зоны спавна (задаются в иснпекторе)
@export var max_enemies: int = 50  # Максимум врагов
@export var wave_interval: float = 2.0 # Интервал между волнами
@export var wave_size: int = 10 # Количество врагов в волне
@export var spawn_interval: float = 1.0  # Интервао спавна
@export var min_spawn_distance: float = 100.0 # Минимальное растояние от игрока
#@export var spawn_radius: float = 500.0 # Радиус зоны спавна

# Прогресс сложности
@export var wave_size_increase: int = 1 # Увеличение размера волны каждый N волн
@export var wave_interval_decrease: float = 0.5 # Уменьшение интервала каждый N волн
@export var difficulty_step: int = 5 # Каждый 5 волн увеличивать сложность

var enemy_count: int = 0
var player: Node2D = null  # Ссылка ни игрока
var enemies_to_spawn: int = 0 # Сколько врагов осталось спавнить в текущей волне
var wave_count: int = 0 # Счетчик волн

@onready var spawn_timer: Timer = %SpawnTimer

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	if spawn_zones.size() == 0:
		print("No spawn zones defined, using random position!")
	spawn_timer.wait_time = wave_interval # Начинаем с паузы перед первой волной
	spawn_timer.timeout.connect(_on_timer_timeout)
	spawn_timer.start()

func _on_timer_timeout() -> void:
	if enemies_to_spawn <= 0:
		# Начинаем новую волну
		wave_count += 1
		update_difficulty()
		enemies_to_spawn = min(wave_size, max_enemies - enemy_count)
		spawn_timer.wait_time = spawn_interval # Быстрый интервал внутри волны
		print("Wave ", wave_count, "started! Enemies to spawn: ", enemies_to_spawn)
	if enemies_to_spawn > 0 and enemy_count < max_enemies and player:
		_spawn_single_enemy()
		enemies_to_spawn -= 1
		if enemies_to_spawn <= 0:
			spawn_timer.wait_time = wave_interval # Долгая пауза после волны
			print("Wave ", wave_count, " finished")
	spawn_timer.start()

func _spawn_single_enemy() -> void:
	var enemy_scene = enemy_scenes[randi() % enemy_scenes.size()]
	var enemy = enemy_scene.instantiate()
	var spawn_pos = get_spawn_position()
	
	enemy.position = spawn_pos
	get_parent().add_child(enemy)
	enemy_count += 1
	enemy.tree_exited.connect(_on_enemy_defeated)
	print("Spawned enemy at: ", spawn_pos)

func get_spawn_position() -> Vector2:
	if spawn_zones.size() > 0:
		# Выбрать случайную зону спавна
		var zone = spawn_zones[randi() % spawn_zones.size()]
		# Добавляем небольшой разброс вокруг зоны
		var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
		var spawn_pos = zone + offset
		# Проверяем минимальное расстояние до игрока
		if spawn_pos.distance_to(player.global_position) < min_spawn_distance:
			return get_spawn_position() # Рекурсия если слишком  близко
		return spawn_pos
	else:
		# Старая логика с кольцом, если зоны не заданы
		var angel = randf() * 2 * PI
		var distance = randf_range(min_spawn_distance, min_spawn_distance + 200.0)
		return player.global_position + Vector2(cos(angel), sin(angel)) * distance

func update_difficulty() -> void:
	if wave_count % difficulty_step == 0:
		wave_size += wave_size_increase
		wave_interval = max(wave_interval - wave_interval_decrease, 1.0) # Не меньше 1 секунды
		print("Difficulty increased! Wave size: ", wave_size, " Wave interval: ", wave_interval) 

func  _on_enemy_defeated() -> void:
	enemy_count -= 1

# Публичные методы для управления спавнером
func  start_spawning() -> void:
	spawn_timer.start()

func stop_spawning() -> void:
	spawn_timer.stop()

func set_spawn_intrval(new_interval: float) -> void:
	spawn_interval = new_interval
	if enemies_to_spawn > 0: # Применяется только внутри волн
		spawn_timer.wait_time = spawn_interval
