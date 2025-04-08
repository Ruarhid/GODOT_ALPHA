extends CharacterBody2D
class_name Player

# Настраиваемые параметры
@export var speed: float = 300.0  # Скорость движения
@export var max_health: int = 100
@export var attack_cooldown: float = 0.5
@export var projectile_scene: PackedScene = preload("res://scenes/player/attacks/projectile.tscn")
var health: int = max_health
var damage_bar_timer: float = 0.0
var attack_timer: float = 0.0
var last_direction: Vector2 = Vector2.DOWN # Для направления анимации
const DAMAGE_BAR_DURATION: float = 2.0  # Время видимости 2 бара

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var main_health_bar: ProgressBar = %MainHealthBar #get_node("res://scenes/player/attacks/projectile.tscn")
@onready var damage_health_bar: ProgressBar = %DamageHealthBar

func  _ready() -> void:
	add_to_group("player")  # Для идентификации другими объектами
	main_health_bar.max_value = max_health
	main_health_bar.value = health
	main_health_bar.visible = true  # Виден всегда
	
	damage_health_bar.max_value = max_health
	damage_health_bar.value = health
	damage_health_bar.visible = false  # Скрыт до урона

func _physics_process(delta: float) -> void:
	var direction = get_input()
	velocity = direction * speed
	move_and_slide()
	update_animation(direction)
	update_health_bars(delta)
	
	attack_timer += delta
	if attack_timer >= attack_cooldown and get_tree().get_nodes_in_group("enemies").size() > 0:
		attack()
		attack_timer = 0.0

func get_input() -> Vector2:
	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		direction.y += 1
		
	direction = direction.normalized()
	if direction != Vector2.ZERO:
		last_direction = direction
	return direction

func update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		animated_sprite.flip_h = direction.x < 0  # Повотор при движении влево
		animated_sprite.play("run")
	else:
		animated_sprite.flip_h = last_direction.x < 0
		animated_sprite.play("idle")

func attack() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position
	
	if enemies.size() > 0:
		# Находим ближайшего врага
		var closest_enemy = null
		var min_distance = INF
		for enemy in enemies:
			var distance = global_position.distance_to(enemy.global_position)
			if distance < min_distance:
				min_distance = distance
				closest_enemy = enemy
		if closest_enemy:
			projectile.direction = (closest_enemy.global_position - global_position).normalized()
		else:
			projectile.direction = last_direction
	else:
		projectile.direction = last_direction
	get_parent().add_child(projectile)

func  take_damage(amount: int) -> void:
	health = clamp(health - amount, 0, max_health)
	damage_health_bar.value = health
	damage_health_bar.visible = true
	damage_bar_timer = DAMAGE_BAR_DURATION
	if health <= 0:
		die()

func update_health_bars(delta: float) -> void:
	main_health_bar.value = health
	if damage_health_bar.visible:
		damage_bar_timer -= delta
		if damage_bar_timer <= 0:
			damage_health_bar.visible = false

func die() -> void:
	print("Player died!")
	#queue_free()
