extends Area2D

# Скорость снаряда
const SPEED = 300.0

# Максимальное расстояние полёта
const MAX_DISTANCE = 300.0

# Направление движения
var direction = Vector2.ZERO

# Начальная позиция снаряда
var start_position = Vector2.ZERO

func _ready():
	# Сохраняем начальную глобальную позицию при создании
	start_position = global_position
	if not is_connected("body_entered", _on_body_entered):
		connect("body_entered", _on_body_entered)

func _physics_process(delta):
	# Двигаем снаряд
	position += direction * SPEED * delta
	
	# Проверяем расстояние от начальной точки
	if global_position.distance_to(start_position) > MAX_DISTANCE:
		queue_free()

func _on_body_entered(body):
	# Проверяем, является ли объект врагом из группы "enemies"
	if body.is_in_group("enemies"):
		body.take_damage(20)  # Наносим урон
		print("Hit enemy: ", body.name)  # Отладка
	# Снаряд уничтожается
	queue_free()
