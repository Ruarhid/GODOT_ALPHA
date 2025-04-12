extends BaseEnemy
class_name FastMouse

func  _ready() -> void:
	super._ready()
	speed = 200
	max_health = 40
	damage = 10
	health = max_health

func update_state() -> void:
	pass
	#print("FastMause is chasing!")

#func on_damage_taken() -> void:
	#print("FastMouse took damage! Health: ", health)

func on_death() -> void:
	super.on_death()
