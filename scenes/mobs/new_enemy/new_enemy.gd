extends BaseEnemy
class_name new_enemy

func  _ready() -> void:
	super._ready()  # Вызов _ready() из BaseEnemy
	speed = 50.0   # Переопределяем скорость
	max_health = 100 # Переопределяем здоровье
	damage = 20      # Переопределяем урон
	attack_cooldown = 2 # Мышь атакует немного медленее
	health = max_health

# Переопределяем только необходимые методы
func update_state() -> void:
	# Можно добавить анимацию или другое поведение
	pass

#func on_damage_taken() -> void:
	#super.die()

func  on_death() -> void:
	super.on_death()
