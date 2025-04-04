# audio_manager.gd
extends Node
class_name AudioSettings

var music_player: AudioStreamPlayer = AudioStreamPlayer.new()
var click_sound: AudioStream = preload("res://assets/audio/click.ogg")
var sfx_pool: Array[AudioStreamPlayer] = [] # Пулл плееров для SFX
const SFX_POOL_SIZE: int = 5 # Количество плееров в пуле

func _ready() -> void:
	add_child(music_player)
	music_player.bus = "Music"
	play_background_music(load("res://assets/audio/background_menu.mp3"))
	_initialize_sfx_pool()
	print("Music player bus: ", music_player.bus)
	print("SFX pool initialized with ", sfx_pool.size(), " players")

func _on_sfx_finished(player: AudioStreamPlayer) -> void:
	player.stream = null # Очистка потока после завершения

# Воспроизведение фоновой музыки
func play_background_music(stream: AudioStream) -> void:
	if not music_player.playing or music_player.stream != stream:
		music_player.stream = stream
		music_player.play()

# Остановка музыки
func stop_background_music() -> void:
	music_player.stop()

# Установка громкости музыки
func  set_music_volume(volume: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume))

# Управление SFX \\\ вызов в любом скрипте AudioManager.play_sfx(load("res://"))
#func  play_sfx(stream: AudioStream) -> void:
	#var sfx_player = AudioStreamPlayer.new()
	#sfx_player.stream = stream
	#sfx_player.bus = "SFX"
	#add_child(sfx_player)
	#sfx_player.play()
	#sfx_player.finished.connect(sfx_player.queue_free) # Удалить плеер после завершения

func  play_sfx(stream: AudioStream) -> void:
	var available_player = _get_available_sfx_player()
	if available_player:
		available_player.stream = stream
		available_player.play()
		print("Playing SFX on bus: ", available_player.bus)

func _initialize_sfx_pool() -> void:
	for i in range(SFX_POOL_SIZE):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_player.finished.connect(_on_sfx_finished.bind(sfx_player))
		sfx_pool.append(sfx_player)

func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_pool:
		if not player.playing:
			return player
	return null # Если все плееры заняты то ни чего не проигрывать

func play_click_sound() -> void:
	play_sfx(click_sound)
