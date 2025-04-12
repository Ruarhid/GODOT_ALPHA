extends Area2D
class_name Experience

@export var experience_value: int = 10 # Количество опыта за муку
@onready var sprite: Sprite2D = %Sprite

func _ready() -> void:
	# Если нет текстуры использовать заглушку
	if not sprite.texture:
		sprite.texture = preload("res://icon.svg")
		sprite.scale = Vector2(0.1, 0.1)
	body_entered.connect(_on_body_entered)
	print("Flour initialized at: ", global_position)

func  _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("Player collected flour: ", experience_value)
		body.add_experience(experience_value)
		queue_free()
