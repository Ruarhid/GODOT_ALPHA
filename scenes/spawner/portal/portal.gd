extends Node2D
class_name Portal

signal spawn_enemies(position: Vector2) # Сигнал для спавна врагов

@onready var sprite: AnimatedSprite2D = %Sprite
@onready var spawn_delay: Timer = %SpawnDelay

func _ready() -> void:
	sprite.play("pulse")
	spawn_delay.timeout.connect(_on_spawn_delay_timeout)
	spawn_delay.start()

func _on_spawn_delay_timeout() -> void:
	emit_signal("spawn_enemies", global_position)
