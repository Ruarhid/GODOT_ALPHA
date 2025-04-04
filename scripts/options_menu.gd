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
# Динамический список разрешений
var available_resolutions: Array[Vector2i] = []
# Ожидание действия переназначения кнопки
var awaiting_input: String = "" 


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
	move_left_button.text = OS.get_keycode_string(config.controls["move_left"])
	move_right_button.text = OS.get_keycode_string(config.controls["move_right"])
	move_up_button.text = OS.get_keycode_string(config.controls["move_up"])
	move_down_button.text = OS.get_keycode_string(config.controls["move_down"])


func _input(event: InputEvent) ->  void:
	if awaiting_input != "" and event is InputEventKey and event.pressed:
		config.controls[awaiting_input] = event.keycode
		_update_button_text(awaiting_input)
		config._apply_controls() # Применение изменений
		awaiting_input = ""
		accept_event() # Предотврашение дальнейшей обработки события

func _start_rebind(action: String) -> void:
	awaiting_input = action
	match action:
		"move_left": move_left_button.text = "Press a key"
		"move_right": move_right_button.text = "Press a key"
		"move_up": move_up_button.text = "Press a key"
		"move_down": move_down_button.text = "Press a key"


func _update_button_text(action: String) -> void:
	match  action:
		"move_left": move_left_button.text = OS.get_keycode_string(config.controls["move_left"])
		"move_right": move_right_button.text = OS.get_keycode_string(config.controls["move_right"])
		"move_up": move_up_button.text = OS.get_keycode_string(config.controls["move_up"])
		"move_down": move_down_button.text = OS.get_keycode_string(config.controls["move_down"])

	

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
