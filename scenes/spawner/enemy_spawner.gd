extends Node2D
class_name EnemySpawner
# Настриваемые параметры
@export var enemy_scenes: Array[PackedScene] = [] # Список сцен врагов
@export var spawn_zones: Array[Node2D] = [] # Зоны спавна (задаются в иснпекторе)
@export var max_enemies: int = 50  # Максимум врагов
@export var wave_interval: float = 2.0 # Интервал между волнами
@export var wave_size: int = 10 # Количество врагов в волне
@export var spawn_interval: float = 1.0  # Интервал спавна
@export var min_spawn_distance: float = 100.0 # Минимальное растояние от игрока
@export var max_spawn_distance: float = 400.0

# Прогресс сложности
@export var wave_size_increase: int = 1 # Увеличение размера волны каждый N волн
@export var wave_interval_decrease: float = 0.5 # Уменьшение интервала каждый N волн
@export var difficulty_step: int = 5 # Каждые 5 волн увеличивать сложность

@export var spawn_zone_count: int = 4
@export var spawn_zone_size: float = 50.0

# Анимация волны
@export var spawn_indicator_texture: Texture2D = preload("res://assets/images/spawn.png")

# Типы волн
enum WaveType { NORMAL, FAST, MIXED}
var wave_types: Array[Dictionary] = [
	{"type": WaveType.NORMAL, "enemies": [0]}, # Только Mouse(индекс 0 в enemy_scenes
	{"type": WaveType.FAST, "enemies": [1]}, # Только FastMous (индекс 1)
	{"type": WaveType.MIXED, "enemies": [0, 1]} # Смешенная волна
]

var enemy_count: int = 0
var player: Node2D = null  # Ссылка на игрока
var enemies_to_spawn: int = 0 # Сколько врагов осталось спавнить в текущей волне
var wave_count: int = 0 # Счетчик волн
var current_wave_type: Dictionary = {}
var current_spawn_zone: Node2D = null

@onready var spawn_timer: Timer = %SpawnTimer

func _ready() -> void:
	randomize()
	player = get_tree().get_first_node_in_group("player")
	if spawn_zones.size() == 0:
		print("No spawn zones defined, using random position!")
	generate_spawn_zones()
	spawn_timer.wait_time = wave_interval # Начинаем с паузы перед первой волной
	spawn_timer.timeout.connect(_on_timer_timeout)
	spawn_timer.start()

func generate_spawn_zones() -> void:
	for zone in spawn_zones:
		zone.queue_free()
	spawn_zones.clear()
	
	for i in range(spawn_zone_count):
		var zone = Node2D.new()
		zone.name = "SpawnZone" + str(i + 1)
		# Анимация
		var indicator = AnimatedSprite2D.new()
		indicator.name = "Indicator"
		indicator.sprite_frames = SpriteFrames.new()
		
		indicator.sprite_frames.add_animation("pulse")
		var frame_width: float = 50.0
		var frame_height: float = 50.0
		
		if spawn_indicator_texture:
			frame_width = spawn_indicator_texture.get_width() / 5.0
			frame_height = spawn_indicator_texture.get_height()
			
			for frame in range(5):
				var region = Rect2(frame * frame_width, 0, frame_width, frame_height)
				var atlas_texture = AtlasTexture.new()
				atlas_texture.atlas = spawn_indicator_texture
				atlas_texture.region = region
				indicator.sprite_frames.add_frame("pulse", atlas_texture)
				
			indicator.sprite_frames.set_animation_speed("pulse", 7.0)
			indicator.sprite_frames.set_animation_loop("pulse", true)
		else:
			print("Warning: No spawn_indocator_texture set!")
		# Маштабирование вне условия
		indicator.scale = Vector2(spawn_zone_size / frame_width, spawn_zone_size / frame_height) if spawn_indicator_texture else Vector2(1.0, 1.0)
		indicator.position = Vector2.ZERO
		indicator.visible = false
		
		zone.add_child(indicator)
		add_child(zone)
		
		var spawn_pos = get_random_zone_position()
		zone.global_position = spawn_pos
		spawn_zones.append(zone)
		print("Created spawn zone at: ", spawn_pos)

func _on_timer_timeout() -> void:
	if enemies_to_spawn <= 0:
		# Начинаем новую волну
		wave_count += 1
		update_difficulty()
		select_wave_type()
		enemies_to_spawn = min(wave_size, max_enemies - enemy_count)
		spawn_timer.wait_time = spawn_interval # Быстрый интервал внутри волны
		highlight_spawn_zone() # Подсветка
		print("Wave ", wave_count, "started! Type: ", WaveType.keys()[current_wave_type["type"]], "Enemies to spawn: ", enemies_to_spawn)
		
	if enemies_to_spawn > 0 and enemy_count < max_enemies and player:
		_spawn_single_enemy()
		enemies_to_spawn -= 1
		if enemies_to_spawn <= 0:
			spawn_timer.wait_time = wave_interval # Долгая пауза после волны
			unhighlight_spawn_zone()
			print("Wave ", wave_count, " finished")
	spawn_timer.start()

func _spawn_single_enemy() -> void:
	var enemy_index = current_wave_type["enemies"][randi() % current_wave_type["enemies"].size()]
	var enemy_scene = enemy_scenes[enemy_index]
	var enemy = enemy_scene.instantiate()
	var spawn_pos = get_spawn_position()
	
	enemy.position = spawn_pos
	get_parent().add_child(enemy)
	enemy_count += 1
	enemy.tree_exited.connect(_on_enemy_defeated)
	print("Spawned enemy at: ", spawn_pos)

func get_spawn_position() -> Vector2:
	if spawn_zones.size() > 0 and current_spawn_zone:
		var attempts = 0
		var max_attempts = 10
		while  attempts < max_attempts:
			var offset = Vector2(randf_range(-50, 50), randf_range(-50, 50))
			var spawn_pos = current_spawn_zone.global_position + offset
			if spawn_pos.distance_to(player.global_position) >= min_spawn_distance:
				return spawn_pos
			attempts += 1
		print("Warning: Couldn't find valid spawn position after ", max_attempts, " attempts!")
		return current_spawn_zone.global_position + Vector2(50, 50)
	else:
		var angle = randf() * 2 * PI
		var distance = randf_range(min_spawn_distance, min_spawn_distance + 200.0)
		return player.global_position + Vector2(cos(angle), sin(angle)) * distance

func get_random_zone_position() -> Vector2:
	var attempts = 0
	var max_attempts = 10 # Ограничение числа попыток
	var spawn_pos = Vector2.ZERO
		
	while attempts < max_attempts:
		var angle = randf() * 2 * PI
		var distance = randf_range(min_spawn_distance + 50.0, max_spawn_distance)
		spawn_pos = player.global_position + Vector2(cos(angle), sin(angle)) * distance
		if spawn_pos.distance_to(player.global_position) >= min_spawn_distance + 50.0:
			return spawn_pos
		attempts += 1
	# Если не нашло подходящую позицию, возвращаем позицию с небольшим смешением
	print("Warning: Coldn't find valid spawn position after ", max_attempts, "attempts!")
	return player.global_position + Vector2(min_spawn_distance + 50.0, 0)

func select_wave_type() -> void:
	current_wave_type = wave_types[randi() % wave_types.size()]
	if spawn_zones.size() > 0:
		current_spawn_zone = spawn_zones[randi() % spawn_zones.size()]

func update_difficulty() -> void:
	if wave_count % difficulty_step == 0:
		wave_size += wave_size_increase
		wave_interval = max(wave_interval - wave_interval_decrease, 1.0) # Не меньше 1 секунды
		print("Difficulty increased! Wave size: ", wave_size, " Wave interval: ", wave_interval) 

func highlight_spawn_zone() -> void:
	if current_spawn_zone:
		if current_spawn_zone.has_node("Indicator"):
			var indicator = current_spawn_zone.get_node("Indicator") as AnimatedSprite2D
			indicator.visible = true
			indicator.play("pulse")

func  unhighlight_spawn_zone() -> void:
	if current_spawn_zone:
		if current_spawn_zone.has_node("Indicator"):
			var indicator = current_spawn_zone.get_node("Indicator") as AnimatedSprite2D
			indicator.stop()
			indicator.visible = false

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
