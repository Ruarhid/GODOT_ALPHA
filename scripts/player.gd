extends CharacterBody2D

# Константа скорости персонажа (можно менять в инспекторе или здесь)
const SPEED = 500.0

# Переменная для хранения последнего направления движения, изначально вниз
var last_direction = Vector2.DOWN

# Ссылка на AnimatedSprite2D, инициализируется при загрузке сцены
@onready var anime = $AnimatedSprite2D

# Функция для обработки ввода от игрока
func get_input():
	# Получаем вектор направления от ввода (ui_left, ui_right, ui_up, ui_down)
	# Возвращает нормализованный Vector2 (от -1 до 1 по осям)
	var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Устанавливаем скорость персонажа: направление * скорость
	velocity = input_direction * SPEED 
	
	# Если есть движение (вектор не нулевой), обновляем последнее направление
	# Это важно для определения анимации покоя
	if input_direction != Vector2.ZERO:
		last_direction = input_direction

# Основной физический процесс, вызывается каждый кадр
func _physics_process(_delta: float) -> void:
	# Получаем ввод и обновляем velocity
	get_input()
	
	# Обновляем анимацию на основе текущей скорости
	update_animation(velocity)
	
	# Двигаем персонажа с учётом физики и столкновений
	move_and_slide()

# Функция для управления анимациями в зависимости от движения
func update_animation(direction: Vector2):
	# Если персонаж движется (вектор скорости не нулевой)
	if direction != Vector2.ZERO:
		# Проверяем, что преобладает: горизонталь (x) или вертикаль (y)
		if abs(direction.x) > abs(direction.y):
			# Движение влево: отзеркаливаем спрайт и играем "run_flip"
			if direction.x < 0:
				anime.flip_h = true  # Переворот спрайта для направления влево
				anime.play("run")
			# Движение вправо: убираем отзеркаливание и играем "run_flip"
			elif direction.x > 0:
				anime.flip_h = false  # Обычное положение для направления вправо
				anime.play("run")
		# Если преобладает вертикаль (движение вверх или вниз)
		else:
			# Движение вниз: играем "run_front"
			# Движение вверх: играем "run_back"
			anime.play("run_front" if direction.y > 0 else "run")
	# Если персонаж стоит на месте (вектор скорости нулевой)
	else:
		# Проверяем последнее направление, чтобы выбрать анимацию покоя
		if abs(last_direction.x) > abs(last_direction.y):
			# Покой влево: отзеркаливаем и играем "idle_flip"
			if last_direction.x < 0:
				anime.flip_h = true  # Переворот для левого направления
				anime.play("idle")
			# Покой вправо: убираем отзеркаливание и играем "idle_flip"
			elif last_direction.x > 0:
				anime.flip_h = false  # Обычное положение для правого направления
				anime.play("idle")
		# Если последнее направление было вертикальным
		else:
			# Покой вниз: играем "idle_front"
			# Покой вверх: играем "idle_back"
			anime.play("idle" if last_direction.y > 0 else "idle")
