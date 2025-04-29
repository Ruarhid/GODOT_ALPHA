extends CharacterBody2D

class_name Player

# Настраиваемые параметры
@export var speed: float = 300.0  # Скорость движения
@export var max_health: int = 100
@export var attack_cooldown: float = 0.5
@export var projectile_scene: PackedScene = preload("res://scenes/player/attacks/projectile.tscn")
@export var experience_per_level: int = 100 # Сколько опыта для уровня
@export var experience_growth: float = 1.2 # Множитель роста опыта

var health: int = max_health
var damage_bar_timer: float = 0.0
var attack_timer: float = 0.0
var last_direction: Vector2 = Vector2.DOWN # Для направления анимации
var experience: int = 0
var level: int = 1
const DAMAGE_BAR_DURATION: float = 2.0  # Время видимости 2 бара

@onready var animated_sprite: AnimatedSprite2D = %AnimatedSprite2D
@onready var main_health_bar: ProgressBar = %MainHealthBar #get_node("res://scenes/player/attacks/projectile.tscn")
@onready var damage_health_bar: ProgressBar = %DamageHealthBar
@onready var experience_bar: ProgressBar = %ExperienceBar

func  _ready() -> void:
	spec_update()
	add_to_group("player")  # Для идентификации другими объектами
	main_health_bar.max_value = max_health
	main_health_bar.value = health
	main_health_bar.visible = true  # Виден всегда
	
	damage_health_bar.max_value = max_health
	damage_health_bar.value = health
	damage_health_bar.visible = false  # Скрыт до урона
	
	experience_bar.max_value =  experience_per_level
	experience_bar.value = 0
	experience_bar.visible = true
	set_meta("projectile_damage", 10)
	print("Player initialized")

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
	
	# Получаем значения осей джойстика
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	# Нормализуем вектор, чтобы избежать ускорения при диагональном движении
	direction = direction.normalized()
	
	# Сохраняем последнюю ненулевую дирекцию
	if direction != Vector2.ZERO:
		last_direction = direction
	
	return direction

func update_animation(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		animated_sprite.flip_h = direction.x > 0  # Повотор при движении влево
		animated_sprite.play("run")
	else:
		animated_sprite.flip_h = last_direction.x < 0
		animated_sprite.play("idle")

func attack() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	# Find closest enemy within 200 units
	var closest_enemy = null
	var min_distance = 200
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
	
	if closest_enemy:
		var projectile = projectile_scene.instantiate()
		projectile.global_position = global_position
		projectile.damage = get_meta("projectile_damage", 10)
		projectile.direction = (closest_enemy.global_position - global_position).normalized()
		get_parent().add_child(projectile)

func take_damage(amount: int) -> void:
	health = clamp(health - amount, 0, max_health)
	damage_health_bar.value = health
	damage_health_bar.visible = true
	damage_bar_timer = DAMAGE_BAR_DURATION
	if health <= 0:
		die()

func add_experience(amount: int) -> void:
	print("Adding experience: ", amount, " Current XP: ", experience + amount)
	experience += amount
	var required_experience = experience_per_level * pow(experience_growth, level - 1)
	experience_bar.max_value = required_experience
	experience_bar.value = experience
	if experience >= required_experience:
		level_up()

func level_up() -> void:
	level += 1
	experience = 0
	experience_bar.value = 0
	experience_bar.max_value = experience_per_level * pow(experience_growth, level - 1)
	print("Level up!  New level: ", level)
	show_upgrade_menu()

func update_experience_ui() -> void:
	pass

func show_upgrade_menu() -> void:
	var upgrade_menu = get_tree().get_first_node_in_group("upgrade_menu")
	if upgrade_menu:
		if not upgrade_menu.visible:
			print("Calling show_menu on UpgradeMenu")
			upgrade_menu.show_menu()
		else:
			print("UpgradeMenu already visible, skipping")
	else:
		print("Upgrade menu not found!")

func update_health_bars(delta: float) -> void:
	main_health_bar.value = health
	if damage_health_bar.visible:
		damage_bar_timer -= delta
		if damage_bar_timer <= 0:
			damage_health_bar.visible = false

func die() -> void:
	pass
	#print("Player died!")
	#queue_free()

func spec_update() -> void:
	$VBoxContainer/health.text = "Health: %s" % max_health
