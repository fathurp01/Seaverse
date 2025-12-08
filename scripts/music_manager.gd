extends Node

var music_player: AudioStreamPlayer
var current_music: String = ""
var is_muted: bool = false  # Status mute global

func _ready():
	# Buat AudioStreamPlayer untuk musik
	music_player = AudioStreamPlayer.new()
	add_child(music_player)
	music_player.bus = "Master"
	# Set autoplay dan loop agar musik terus berulang
	music_player.autoplay = false
	# Reconnect signal untuk loop musik secara manual
	music_player.finished.connect(_on_music_finished)

func play_opening_music():
	"""Memutar Opening Music (untuk start screen dan zone menu)"""
	var music_path = "res://assets/sounds/Opening_Music.mp3"
	
	# Jika musik yang sama sudah diputar, jangan restart
	if current_music == music_path and music_player.playing:
		return
	
	var music_stream = load(music_path)
	if music_stream:
		music_player.stream = music_stream
		music_player.play()
		current_music = music_path
		print("Playing Opening Music")

func play_exploration_music(zone_name: String):
	"""Memutar musik eksplorasi berdasarkan zona"""
	var music_path = ""
	
	match zone_name:
		"permukaan":
			music_path = "res://assets/sounds/Exploration_Music_Permukaan.mp3"
		"tengah":
			music_path = "res://assets/sounds/Exploration_Music_Pertengahan.mp3"
		"dasar":
			music_path = "res://assets/sounds/Exploration_Music_Dasar.mp3"
	
	if music_path == "":
		return
	
	# Jika musik yang sama sudah diputar, jangan restart
	if current_music == music_path and music_player.playing:
		return
	
	var music_stream = load(music_path)
	if music_stream:
		music_player.stream = music_stream
		music_player.play()
		current_music = music_path
		print("Playing Exploration Music: ", zone_name)

func stop_music():
	"""Menghentikan musik yang sedang diputar"""
	if music_player.playing:
		music_player.stop()
		current_music = ""
		print("Music stopped")

func set_volume(volume_db: float):
	"""Mengatur volume musik (-80 hingga 0 dB)"""
	music_player.volume_db = volume_db
	# Update status mute berdasarkan volume
	is_muted = (volume_db <= -80)

func is_playing() -> bool:
	"""Check apakah musik sedang diputar"""
	return music_player.playing

func _on_music_finished():
	"""Callback ketika musik selesai - replay musik yang sama"""
	if current_music != "" and music_player.stream:
		music_player.play()
		print("Music looped: ", current_music)
