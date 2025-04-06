extends CharacterBody2D

# Константа скорости мыши
const SPEED = 50.0
const STOP_DISTANCE = 20.0

# Здоровье мыши
var health = 100

# Ссылка на игрока
var player = null

# Ссылка на анимацию мыши
@onready var anime = $AnimatedSprite2D

func _ready():
	# Находим игрока в сцене
	player = get_parent().get_node("Player")
	# Добавляем мышь в группу "enemies"
	add_to_group("enemies")

func _physics_process(_delta):
	$ProgressBar.value = health
	
	if player != null:
		var distance_to_player = global_position.distance_to(player.global_position)
		if distance_to_player > STOP_DISTANCE:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * SPEED
			update_animation(direction)
		else:
			velocity = Vector2.ZERO
			update_animation(Vector2.ZERO)
		move_and_slide()

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
			anime.play("run")

func take_damage(amount):
	health -= amount
	print("Mouse health: ", health)
	if health <= 0:
		print("Mouse died!")
		queue_free()  # Уничтожаем мышь
