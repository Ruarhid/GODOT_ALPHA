extends CharacterBody2D

# Константа скорости мыши
const SPEED = 200.0

# Ссылка на игрока (будет установлена извне или найдена в сцене)
var player = null

# Ссылка на анимацию мыши
@onready var anime = $AnimatedSprite2D

func _ready():
	# Находим игрока в сцене по имени (предполагается, что узел называется "Player")
	player = get_parent().get_node("Player")
	# Если структура сцены другая, нужно будет скорректировать путь, например:
	# player = get_parent().get_node("Player")

func _physics_process(_delta):
	# Проверяем, что игрок существует
	if player != null:
		# Вычисляем направление к игроку
		var direction = (player.global_position - global_position).normalized()
		
		# Устанавливаем скорость в направлении игрока
		velocity = direction * SPEED
		
		# Обновляем анимацию (если она есть)
		update_animation(direction)
		
		# Двигаем мышь с учётом физики
		move_and_slide()

# Функция для управления анимацией (аналогично игроку)
func update_animation(direction: Vector2):
	if direction != Vector2.ZERO:
		# Проверяем горизонтальное или вертикальное направление
		if abs(direction.x) > abs(direction.y):
			# Влево: отзеркаливаем спрайт
			if direction.x < 0:
				anime.flip_h = true
				anime.play("run")
			# Вправо: обычное положение
			elif direction.x > 0:
				anime.flip_h = false
				anime.play("run")
		# Вертикальное движение пока использует "run"
		else:
			anime.play("run")
