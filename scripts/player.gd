extends CharacterBody2D

# Константа скорости персонажа
const SPEED = 500.0

# Переменная здоровья игрока
var health = 100

# Переменная для хранения последнего направления движения, изначально вниз
var last_direction = Vector2.DOWN

# Ссылка на AnimatedSprite2D
@onready var anime = $AnimatedSprite2D

# Переменные для урона от врага
var is_enemy_inside = false
var damage_timer = 0.0
const DAMAGE_INTERVAL = 1.0
const DAMAGE_AMOUNT = 10

# Переменные для автоатаки
var attack_timer = 0.0
const ATTACK_INTERVAL = 0.5  # Снаряд каждые 0.5 секунды
const PROJECTILE_SCENE = preload("res://scenes/weapons/default_atack/default_attack.tscn")

func _ready():
	%ProgressBar2.visible = false
	# Подключаем сигналы Area2D
	$Area2D.body_entered.connect(_on_area_2d_body_entered)
	$Area2D.body_exited.connect(_on_area_2d_body_exited)

func _physics_process(_delta: float) -> void:
	# Обновляем прогресс-бар
	%ProgressBar.value = health
	
	if health < 100:
		%ProgressBar2.visible = true
		%ProgressBar2.value = health
	
	# Обрабатываем ввод и движение
	get_input()
	update_animation(velocity)
	move_and_slide()
	
	# Постепенный урон от врага
	if is_enemy_inside:
		damage_timer += _delta
		if damage_timer >= DAMAGE_INTERVAL:
			health -= DAMAGE_AMOUNT
			print("Player health: ", health)
			damage_timer = 0.0
			if health <= 0:
				print("Player died!")
				# queue_free()

	# Автоатака
	attack_timer += _delta
	if attack_timer >= ATTACK_INTERVAL:
		fire_projectile()
		attack_timer = 0.0

func get_input():
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = input_direction * SPEED 
	if input_direction != Vector2.ZERO:
		last_direction = input_direction

func update_animation(direction: Vector2):
	if direction != Vector2.ZERO:
		if abs(direction.x) > abs(direction.y):
			if direction.x < 0:
				anime.flip_h = true
				anime.play("run")
			elif direction.x > 0:
				anime.flip_h = false
				anime.play("run")
		else:
			anime.play("run" if direction.y > 0 else "run")
	else:
		if abs(last_direction.x) > abs(last_direction.y):
			if last_direction.x < 0:
				anime.flip_h = true
				anime.play("idle")
			elif last_direction.x > 0:
				anime.flip_h = false
				anime.play("idle")
		else:
			anime.play("idle" if last_direction.y > 0 else "idle")

func _on_area_2d_body_entered(body):
	if body.name == "Mouse":
		is_enemy_inside = true
		health -= DAMAGE_AMOUNT
		print("Player health: ", health)
		damage_timer = 0.0

func _on_area_2d_body_exited(body):
	if body.name == "Mouse":
		is_enemy_inside = false

func fire_projectile():
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.size() > 0:
		# Ищем ближайшего врага
		var closest_enemy = null
		var min_distance = INF  # Бесконечность как начальное значение
		for enemy in enemies:
			var distance = global_position.distance_to(enemy.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_enemy = enemy
		
		# Задаём направление к ближайшему врагу
		var direction = (closest_enemy.global_position - global_position).normalized()
		
		# Создаём снаряд
		var projectile = PROJECTILE_SCENE.instantiate()
		projectile.global_position = global_position
		projectile.direction = direction
		get_parent().add_child(projectile)
