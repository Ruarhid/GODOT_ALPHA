extends Area2D
class_name Projectile

@export var speed: float = 400.0
var direction: Vector2 = Vector2.RIGHT

@onready var notifier: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

func  _ready() -> void:
	body_entered.connect(_on_body_entered)
	notifier.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		body.take_damage(10)
		queue_free()

func  _on_screen_exited() -> void:
	queue_free() # Удалить если улетел за экран
