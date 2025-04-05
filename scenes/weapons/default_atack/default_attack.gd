extends Area2D

# Скорость снаряда
const SPEED = 300.0

# Направление движения
var direction = Vector2.ZERO

func _ready():
	# Подключаем сигнал
	connect("body_entered", _on_body_entered)

func _physics_process(delta):
	# Двигаем снаряд
	position += direction * SPEED * delta
	
	# Уничтожаем, если снаряд далеко от начала (опционально)
	if position.length() > 1000:
		queue_free()

func _on_body_entered(body):
	# Проверяем, что попали во врага
	if body.name == "Mouse":
		body.take_damage(20)  # Наносим 20 урона
		queue_free()  # Уничтожаем снаряд
