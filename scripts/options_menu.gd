# options.gd
extends Control
class_name OptionsMenu

@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SFXSlider
@onready var resolution_option: OptionButton = %ResolutionOption
@onready var fullscreen_check: CheckButton = %FullscreenCheck
@onready var back_button: Button = %BackButton as Button
@onready var save_button: Button = %SaveButton as Button
@onready var default_button: Button = %DefaultButton as Button
@onready var move_left_button: Button = %MoveLeftButton
@onready var move_right_button: Button = %MoveRightButton
@onready var move_up_button: Button = %MoveUpButton
@onready var move_down_button: Button = %MoveDownButton


var config: GameConfig = Settings
var available_resolutions: Array[Vector2i] = [] # Динамический список разрешений
var awaiting_input: String = "" # Ожидание действия переназначения кнопки

func _ready() -> void: 
	_setup_resolution_options()
	_connect_signals()
	_load_current_settings()

func _setup_resolution_options() -> void:
	resolution_option.clear()
	# Получение максимального разрешения
	var max_size = DisplayServer.screen_get_size()
	# Список популярных разрешений
	var resolutions = [Vector2i(800, 600), Vector2i(1024, 768), Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080), Vector2i(2560, 1440), Vector2i(3840, 2160)]
	available_resolutions = []
	for res in resolutions:
		if res.x <= max_size.x and res.y <= max_size.y: # Проверка поддержки разрешений
			available_resolutions.append(res)
			resolution_option.add_item("%dx%d" % [res.x, res.y])
	# Установка текушего разрешения
	var current_idx = available_resolutions.find(config.resolution)
	if current_idx != -1:
		resolution_option.selected = current_idx
	else:
			resolution_option.selected = available_resolutions.find(Vector2i(1920, 1080)) # Значение по умолчанию

func _connect_signals() -> void:
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	back_button.pressed.connect(_on_back_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	default_button.pressed.connect(_on_default_button_pressed)
	resolution_option.item_selected.connect(_on_resolution_selected)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	move_left_button.pressed.connect(_start_rebind.bind("move_left"))
	move_right_button.pressed.connect(_start_rebind.bind("move_right"))
	move_up_button.pressed.connect(_start_rebind.bind("move_up"))
	move_down_button.pressed.connect(_start_rebind.bind("move_down"))


func _load_current_settings() -> void: # Загрузка текуших настроек
	master_slider.value = config.master_volume
	music_slider.value = config.music_volume
	sfx_slider.value = config.sfx_volume
	var current_idx = available_resolutions.find(config.resolution)
	if current_idx != -1:
		resolution_option.selected = current_idx
	fullscreen_check.button_pressed = config.fullscreen
	move_left_button.text = _get_control_string("move_left")
	move_right_button.text = _get_control_string("move_right")
	move_up_button.text = _get_control_string("move_up")
	move_down_button.text = _get_control_string("move_down")


func _input(event: InputEvent) -> void:
	if awaiting_input != "":
		if event is InputEventKey and event.pressed:
			config.controls[awaiting_input] = {"type": "key", "value": event.keycode}
			_update_button_text(awaiting_input)
			config._apply_controls() # Применение изменений
			awaiting_input = ""
			accept_event() # Предотврашение дальнейшей обработки события
		elif event is InputEventJoypadButton and event.pressed:
			config.controls[awaiting_input] = {"type": "joypad_button", "value": event.button_index}
			_update_button_text(awaiting_input)
			config._apply_controls()
			awaiting_input = ""
			accept_event()
		elif event is InputEventJoypadMotion:
			var axis_value = event.axis_value
			if abs(axis_value) >  0.5: # Чувствительность для стиков
				var direction = 1 if axis_value > 0 else -1
				config.controls[awaiting_input] = {"type": "joypad_axis", "value": event.axis, "direction": direction}
				_update_button_text(awaiting_input)
				config._apply_controls()
				awaiting_input = ""
				accept_event()

func _start_rebind(action: String) -> void:
	awaiting_input = action
	var original_text = _get_control_string(action) # Сохранить исходный текс
	match action:
		"move_left": move_left_button.text = "Press a key button, or move stick..."
		"move_right": move_right_button.text = "Press a key button, or move stick..."
		"move_up": move_up_button.text = "Press a key button, or move stick..."
		"move_down": move_down_button.text = "Press a key button, or move stick..."
	# Запуск таймера на 5 секунд
	await get_tree().create_timer(5.0).timeout
	# Если ввод всё ещё ожидается, вернуть исходный текст
	if awaiting_input == action:
		awaiting_input = ""
		match  action:
			"move_left": move_left_button.text = original_text
			"move_right": move_right_button.text = original_text
			"move_up": move_up_button.text = original_text
			"move_down": move_down_button.text = original_text

func _update_button_text(action: String) -> void:
	match  action:
		"move_left": move_left_button.text = _get_control_string("move_left")
		"move_right": move_right_button.text = _get_control_string("move_right")
		"move_up": move_up_button.text = _get_control_string("move_up")
		"move_down": move_down_button.text = _get_control_string("move_down")

func _get_control_string(action: String) -> String:
	var control = config.controls[action]
	if control["type"] == "key":
		return OS.get_keycode_string(control["value"])
	elif control["type"] == "joypad_button":
		match control["value"]:
			JOY_BUTTON_A : return "A"
			JOY_BUTTON_B : return "B"
			JOY_BUTTON_X : return "X"
			JOY_BUTTON_Y : return "Y"
			JOY_BUTTON_LEFT_SHOULDER : return "LB"
			JOY_BUTTON_RIGHT_SHOULDER : return "RB"
			JOY_BUTTON_LEFT_STICK : return "L3"
			JOY_BUTTON_RIGHT_STICK : return "R3"
			JOY_BUTTON_START : return "Start"
			JOY_BUTTON_BACK : return "Back"
			_: return "Button " + str(control["value"])
	elif control["type"] == "joypad_axis":
		var direction_str = " +" if control["direction"] > 0 else " -"
		match control["value"]:
			JOY_AXIS_LEFT_X: return "Left Stick X" + direction_str
			JOY_AXIS_LEFT_Y: return "Left Stick Y" + direction_str
			JOY_AXIS_RIGHT_X: return "Right Stick X" + direction_str
			JOY_AXIS_RIGHT_Y: return "Right Stick Y" + direction_str
			JOY_AXIS_TRIGGER_LEFT: return "Left Trigger"
			JOY_AXIS_TRIGGER_RIGHT: return "Right Trigger"
			_: return "Axis " + str(control["value"]) + direction_str
	return "Unknown"

func _on_master_changed(value: float) -> void:
	config.master_volume = value

func _on_music_changed(value: float) ->  void:
	config.music_volume = value

func  _on_sfx_changed(value: float) -> void:
	config.sfx_volume = value

func _on_resolution_selected(index: int) -> void:
	config.resolution = available_resolutions[index]

func _on_fullscreen_toggled(button_pressed: bool) -> void:
	config.fullscreen = button_pressed

func _on_default_button_pressed() -> void:
	config.reset_to_default()
	_load_current_settings()

func  _on_save_button_pressed() -> void:
	config.save_settings()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
