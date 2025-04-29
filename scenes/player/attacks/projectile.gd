extends Area2D
class_name Projectile

@export var speed: float = 400.0
@export var damage: int = 10
@export var MAX_DISTANCE = 500

var start_position: Vector2
var direction: Vector2 = Vector2.RIGHT

@onready var notifier: VisibleOnScreenNotifier2D = %VisibleOnScreenNotifier2D

func  _ready() -> void:
	start_position = global_position
	body_entered.connect(_on_body_entered)
	print("Projectile  spawmed")
	print("start_position", start_position)
	notifier.screen_exited.connect(_on_screen_exited)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	var nnn = global_position.distance_to(start_position)
	if nnn > MAX_DISTANCE:
		print("nnn - ", nnn)
		queue_free()
	#if start_position > MAX_DISTANCE:
		#queue_free()

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("enemies"):
		print("Projectile hit enemy, dealing damage: ", damage)
		body.take_damage(damage)
		queue_free()

func  _on_screen_exited() -> void:
	print("GG")
	queue_free() # Удалить если улетел за экран

func attack() -> void:
	var enemies = get_tree().get_nodes_in_group("enemies")
	if enemies.is_empty():
		return
	
	# Find closest enemy within 200 units
	var closest_enemy = null
	var min_distance = MAX_DISTANCE
	
	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < min_distance:
			min_distance = distance
			closest_enemy = enemy
	
	if closest_enemy:
		var projectile = global_position
		projectile.damage = get_meta("projectile_damage", 10)
		projectile.direction = (closest_enemy.global_position - global_position).normalized()
		get_parent().add_child(projectile)
