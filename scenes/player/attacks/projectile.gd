extends Area2D
class_name Projectile

@export var speed: float = 400.0
@export var damage: int = 10
var direction: Vector2 = Vector2.RIGHT

@onready var notifier: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

func  _ready() -> void:
	body_entered.connect(_on_body_entered)
	print("Projectile  spawmed")
	notifier.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		print("Projectile hit enemy, dealing damage: ", damage)
		body.take_damage(damage)
		queue_free()

func  _on_screen_exited() -> void:
	queue_free() # Удалить если улетел за экран
