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
		print("Master volume set to: ", master_volume)
		#_update_all_buses() # Обновляет все дочерние шины

var music_volume: float = 1.0:
	set(value):
		music_volume = clamp(value, 0.0, 1.0)
		#_update_bus_volume("Music", music_volume)
		print("Music volume set to: ", music_volume)
		AudioManager.set_music_volume(music_volume)

var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clamp(value, 0.0, 1.0)
		_update_bus_volume("SFX", sfx_volume) # Учитываем Master
		print("SFX volume set to: ", sfx_volume)

# Настройки разрешения экрана
var resolution: Vector2i = Vector2i(1920, 1080): # Разрешение по умолчанию
	set(value):
		resolution = value.clamp(Vector2i(800, 600), DisplayServer.screen_get_size()) # Ограничение
		DisplayServer.window_set_size(resolution)

var fullscreen: bool = false:
	set(value):
		fullscreen = value
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

# Настройки управления
var controls: Dictionary = {
	"move_left": {"type": "key", "value": KEY_A},
	"move_right": {"type": "key", "value": KEY_D},
	"move_up": {"type": "key", "value": KEY_W},
	"move_down": {"type": "key", "value": KEY_S}
}

func _ready() -> void:
	load_settings()
	_apply_settings() # Применяет настройки при запуске

func _update_bus_volume(bus_name: String, value: float) -> void:
	var bus_idx = AudioServer.get_bus_index(bus_name) # Получение индекса аудиошины по имени
	if bus_idx != -1: # Проверка на существование шины
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	else:
		print("Error: Bus ", bus_name, " not found!")

#func _update_all_buses() -> void:
	#_update_bus_volume("Music", music_volume * master_volume)
	#_update_bus_volume("SFX", sfx_volume * master_volume)

func save_settings() -> void:
	config_file.set_value("Audio", "master_volume", master_volume)
	config_file.set_value("Audio", "music_volume", music_volume)
	config_file.set_value("Audio", "sfx_volume", sfx_volume)
	config_file.set_value("Display", "resolution_x", resolution.x)
	config_file.set_value("Display", "resolution_y", resolution.y)
	config_file.set_value("Display", "fullscreen", fullscreen)
	for action in controls.keys():
		config_file.set_value("Controls", action + "_type", controls[action]["type"])
		config_file.set_value("Controls", action + "_value", controls[action]["value"])
		if controls[action]["type"] == "joypad_axis":
			config_file.set_value("Controls", action + "_derection", controls[action]["direction"])
	var err = config_file.save(CONFIG_PATH)
	if err == OK:
		print("Settings save successfully")
	else :
		print("Failed to save settings: ", err)
	

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
			controls[action]["type"] = config_file.get_value("Controls", action + "_type", "key")
			controls[action]["value"] = config_file.get_value("Controls", action + "_value", controls[action]["value"])
			if controls[action]["type"] == "joypad_axis":
				controls[action]["direction"] = config_file.get_value("Controls", action + "_direction", 1)
		print("Settings loaded: Master=", master_volume, " Music=", music_volume, " SFX=", sfx_volume)
	else:
		reset_to_default() # Если файла нет, использовать по умолчанию
		print("No config file found, reset to default")
	_apply_controls()


func reset_to_default() -> void:
	master_volume = 1.0
	music_volume = 1.0
	sfx_volume = 1.0
	resolution = Vector2i(1920, 1080)
	fullscreen = false
	controls = {
	"move_left": {"type": "key", "value": KEY_A},
	"move_right": {"type": "key", "value": KEY_D},
	"move_up": {"type": "key", "value": KEY_W},
	"move_down": {"type": "key", "value": KEY_S}
	}
	save_settings()

func _apply_controls() -> void:
	for action in controls.keys():
		# Получаем текущее событие и удаляем их
		var events = InputMap.action_get_events(action)
		for event in events:
			InputMap.action_erase_event(action, event)
		var control = controls[action]
		if control["type"] == "key":
			# Добовляем новое событие
			var event = InputEventKey.new()
			event.keycode = control["value"]
			InputMap.action_add_event(action, event)
		elif control["type"] == "joypad_button":
			var event = InputEventJoypadButton.new()
			event.button_index = control["value"]
			InputMap.action_add_event(action, event)
		elif control["type"] == "joypad_axis":
			var event = InputEventJoypadMotion.new()
			event.axis = control["value"]
			event.axis_value = control["direction"] # +1 или -1 для направления
			InputMap.action_add_event(action, event)

func _apply_settings() -> void:
	_update_bus_volume("Master", master_volume)
	_update_bus_volume("Music", music_volume)
	#_update_bus_volume("SFX", sfx_volume)
	AudioManager.set_music_volume(music_volume)
	DisplayServer.window_set_size(resolution)
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
	_apply_controls()
	print("Applied settings - Master: ", master_volume, " Music: ", music_volume, " SFX: ", sfx_volume)
