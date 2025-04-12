# base_enemy.gd
extends CharacterBody2D
class_name BaseEnemy

# Настраиваемые параметры движения
@export var speed: float = 100.0
@export var min_distance: float = 55.0 # Минимальная дистанция до игрока
@export var separation_force: float = 300 # Сила отталкивания от других врагов

# Настраиваемые параметры боя
@export var max_health: int = 50
@export var damage: int = 10
@export var attack_range: float = 70.0  # Дистанция для нанесения урона
@export var attack_cooldown: float = 1.0

# Дроп опыта
@export var experience_drop: int = 10 # Количество опыта за врага
@export var experience_drop_chance: float = 0.8 # Шанс дропа (80%)

# Внитренние переменные
var health: int
var target: Node2D = null
var can_attack: bool = true
var attack_timer: float = 0.0

# Узлы
@onready var damage_area: Area2D = %DamageArea

func _ready() -> void:
	add_to_group("enemies")
	health = max_health
	target = get_tree().get_first_node_in_group("player")
	if not target:
		print("No player found!")
	print("Emeny initialized with health ", health)

func _physics_process(delta: float) -> void:
	if health <= 0 or not target:
		return
	# Обработка движения
	handle_movement(delta)
	# Обработка боя
	handle_combat(delta)
	# Обновление состояний (для анимации и др.)
	update_state()

# МЕТОДЫ ДВИЖЕНИЯ
func handle_movement(delta: float) -> void:
	var move_vector = calculate_move_vector(delta)
	velocity = move_vector
	move_and_slide()

func calculate_move_vector(delta: float) -> Vector2:
	if not target:
		return Vector2.ZERO
		
	# Базовые движения к игроку
	var direction = (target.global_position - global_position).normalized()
	var distance = global_position.distance_to(target.global_position)
	# Базовая скорость к игроку с учетом дистанции
	var desired_velocity = Vector2.ZERO
	if distance > min_distance: #+5.0:
		desired_velocity = direction * speed
	elif distance < min_distance - 10.0:
		desired_velocity = -direction * speed #* 0.5
	# Отталкивание от других врагов
	var separation = calculate_separation()
	# Финальный вектор движения
	return desired_velocity + (separation * separation_force * delta)

func calculate_separation() -> Vector2:
	var separation = Vector2.ZERO
	var nearby_enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in nearby_enemies:
		if enemy != self:
			var dist_to_enemy = global_position.distance_to(enemy.global_position)
			if dist_to_enemy < min_distance:
				var away_direction = (global_position - enemy.global_position).normalized()
				separation += away_direction * (min_distance - dist_to_enemy)
	# Отталкивание от игрока
	if target:
		var dist_to_player = global_position.distance_to(target.global_position)
		if dist_to_player < min_distance:
			var away_from_player = (global_position - target.global_position).normalized()
			separation += away_from_player * (min_distance - dist_to_player) * 2.0 #0.5
	return separation

# МЕТОДЫ БОЯ
func handle_combat(delta: float) -> void:
	if not can_attack:
		attack_timer += delta
		if attack_timer >= attack_cooldown:
			can_attack = true
			attack_timer = 0.0
	if can_attack and is_player_in_attack_range():
		print("Attack player! Distance: ", global_position.direction_to(target.global_position))
		attack_player()

func is_player_in_attack_range() -> bool:
	if not target:
		return false
	return global_position.distance_to(target.global_position) <= attack_range

func attack_player() -> void:
	if target and can_attack:
		can_attack = false
		target.take_damage(damage)
		on_attack_performed() # Событие для наследников

# МЕТОДЫ ЗДОРОВЬЯ И УРОНА
func take_damage(amount: int) -> void:
	print("Enemy took damage: ", amount, " Current health ", health)
	health = clamp(health - amount, 0, max_health)
	if health <= 0:
		print("Emeny health reached 0, calling die()")
		die()
	else:
		on_damage_taken()

# МЕТОДЫ ДЛЯ ПЕРЕОПРЕДЕЛЕНИЯ В НАСЛЕДНИКАХ
func update_state() -> void: # Для анимации и др.
	pass

func on_damage_taken() -> void: # Реакция на урон
	pass

func on_attack_performed() -> void: # Действие при атаке
	pass

func die() -> void:
	print("Enemy die() called")
	on_death()
	queue_free()

func on_death() -> void: # Действия после смерти
	print("Enemy on_death() called, attempting to drop flour")
	if randf() <= experience_drop_chance:
		print("Дропаем опыт: ", experience_drop, " в позиции ", global_position)
		var flour = preload("res://scenes/experience/experience.tscn").instantiate()
		flour.experience_value = experience_drop
		flour.global_position = global_position
		get_parent().call_deferred("add_child", flour)
