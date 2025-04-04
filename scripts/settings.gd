# settings.gd
extends Node
class_name GameConfig

const CONFIG_PATH = "res://settings.cfg"  # "user://settings.cfg"
var config_file: ConfigFile = ConfigFile.new()

# Настройка аудио
var master_volume: float = 1.0:
	set(value):
		master_volume = clamp(value, 0.0, 1.0)
		_update_bus_volume("Master", master_volume)

var music_volume: float = 1.0:
	set(value):
		music_volume = clamp(value, 0.0, 1.0)
		AudioManager.set_music_volume(music_volume)

var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clamp(value, 0.0, 1.0)
		_update_bus_volume("SFX", sfx_volume)

# Настройки разрешения экрана
var resolution: Vector2i = Vector2i(1920, 1080): # Разрешение по умолчанию
	set(value):
		resolution = value.clamp(Vector2i(800, 600), DisplayServer.screen_get_size()) # ограничение
		DisplayServer.window_set_size(resolution)

var fullscreen: bool = false:
	set(value):
		fullscreen = value
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

# Настройки управления
var controls: Dictionary = {
	"move_left": KEY_A,
	"move_right": KEY_D,
	"move_up": KEY_W,
	"move_down": KEY_S,
	"jump": KEY_SPACE
}

func _ready() -> void:
	load_settings()
	_apply_settings() # Применяет настройки при запуске

func _update_bus_volume(bus_name: String, value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name) # Получение индекса аудиошины по имени
	if bus_idx != -1: # Проверка на существование шины
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func save_settings() -> void:
	config_file.set_value("Audio", "master_volume", master_volume)
	config_file.set_value("Audio", "music_volume", music_volume)
	config_file.set_value("Audio", "sfx_volume", sfx_volume)
	config_file.set_value("Display", "resolution_x", resolution.x)
	config_file.set_value("Display", "resolution_y", resolution.y)
	config_file.set_value("Display", "fullscreen", fullscreen)
	for action in controls.keys():
		config_file.set_value("Controls", action, controls[action])
	config_file.save(CONFIG_PATH)

func load_settings() -> void:
	if config_file.load(CONFIG_PATH) == OK:
		master_volume = config_file.get_value("Audio", "master_volume", 1.0)
		music_volume = config_file.get_value("Audio", "music_volume", 1.0)
		sfx_volume = config_file.get_value("Audio", "sfx_volume", 1.0)
		resolution = Vector2i(
			config_file.get_value("Display", "resolution_x", 1920),
			config_file.get_value("Display", "resolution_y", 1080)
		)
		fullscreen = config_file.get_value("Display", "fullscreen", false)
		for action in controls.keys():
			controls[action] = config_file.get_value("Controls", action, controls[action])
	else:
		reset_to_default() # Если файла нет, использовать по умолчанию

func reset_to_default() -> void:
	master_volume = 1.0
	music_volume = 1.0
	sfx_volume = 1.0
	resolution = Vector2i(1920, 1080)
	fullscreen = false
	controls = {
	"move_left": KEY_A,
	"move_right": KEY_D,
	"move_up": KEY_W,
	"move_down": KEY_S,
	"jump": KEY_SPACE
	}
	save_settings()

func _apply_controls() -> void:
	for action in controls.keys():
		# Получаем текущее событие и удаляем их
		var events = InputMap.action_get_events(action)
		for event in events:
			InputMap.action_erase_event(action, event)
		# Добовляем новое событие
		var event = InputEventKey.new()
		event.keycode = controls[action]
		InputMap.action_add_event(action, event)

func _apply_settings() -> void:
	_update_bus_volume("Master", master_volume)
	_update_bus_volume("SFX", sfx_volume)
	AudioManager.set_music_volume(music_volume)
	DisplayServer.window_set_size(resolution)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
