extends Control

# Node references untuk setiap zona
@onready var zona_permukaan = $ZonasContainer/ZonaPermukaan
@onready var zona_tengah = $ZonasContainer/ZonaTengah
@onready var zona_dasar = $ZonasContainer/ZonaDasar

# Status unlock untuk setiap zona (nanti bisa disimpan di global/save system)
var zona_permukaan_unlocked = true
var zona_tengah_unlocked = false
var zona_dasar_unlocked = false

func _ready():
	# Pastikan musik opening tetap berjalan
	MusicManager.play_opening_music()
	
	# Set initial state untuk setiap zona
	_update_zona_states()

func _process(delta):
	# Tombol ESC untuk kembali ke start screen
	if Input.is_action_just_pressed("ui_cancel"):
		go_back()

func _update_zona_states():
	# Zona Permukaan
	_set_zona_state(zona_permukaan, zona_permukaan_unlocked)
	
	# Zona Tengah
	_set_zona_state(zona_tengah, zona_tengah_unlocked)
	
	# Zona Dasar
	_set_zona_state(zona_dasar, zona_dasar_unlocked)

func _set_zona_state(zona: Control, is_unlocked: bool):
	var button = zona.get_node("Button")
	var lock_icon = zona.get_node("LockIcon")
	
	button.disabled = not is_unlocked
	lock_icon.visible = not is_unlocked
	
	# Jika locked, buat sedikit gelap/dimmed
	if not is_unlocked:
		zona.modulate = Color(0.6, 0.6, 0.6, 1.0)
	else:
		zona.modulate = Color(1, 1, 1, 1)

# === ZONA PERMUKAAN HANDLERS ===
func _on_zona_permukaan_mouse_entered():
	pass

func _on_zona_permukaan_mouse_exited():
	pass

func _on_zona_permukaan_pressed():
	if zona_permukaan_unlocked:
		print("Navigating to Zona Permukaan...")
		# Stop musik opening saat masuk eksplorasi
		MusicManager.stop_music()
		# Nanti ganti scene ke zona_permukaan.tscn
		get_tree().change_scene_to_file("res://scenes/explorations/zona_permukaan.tscn")

# === ZONA TENGAH HANDLERS ===
func _on_zona_tengah_mouse_entered():
	pass

func _on_zona_tengah_mouse_exited():
	pass

func _on_zona_tengah_pressed():
	if zona_tengah_unlocked:
		print("Navigating to Zona Tengah...")
		# Stop musik opening saat masuk eksplorasi
		MusicManager.stop_music()
		# Nanti ganti scene ke zona_tengah.tscn
		get_tree().change_scene_to_file("res://scenes/explorations/zona_tengah.tscn")

# === ZONA DASAR HANDLERS ===
func _on_zona_dasar_mouse_entered():
	pass

func _on_zona_dasar_mouse_exited():
	pass

func _on_zona_dasar_pressed():
	if zona_dasar_unlocked:
		print("Navigating to Zona Dasar...")
		# Stop musik opening saat masuk eksplorasi
		MusicManager.stop_music()
		# Nanti ganti scene ke zona_dasar.tscn
		get_tree().change_scene_to_file("res://scenes/explorations/zona_dasar.tscn")

# === UNLOCK SYSTEM (untuk testing atau dipanggil dari sistem progress) ===
func unlock_zona_tengah():
	"""Unlock zona tengah setelah menyelesaikan zona permukaan"""
	zona_tengah_unlocked = true
	_update_zona_states()
	print("Zona Tengah telah dibuka!")

func unlock_zona_dasar():
	"""Unlock zona dasar setelah menyelesaikan zona tengah"""
	zona_dasar_unlocked = true
	_update_zona_states()
	print("Zona Dasar telah dibuka!")

# Fungsi untuk check progress (nanti bisa dipanggil dari global/autoload)
func check_and_unlock_zones():
	"""
	Fungsi ini bisa dipanggil untuk check progress player
	Nanti bisa integrate dengan save system atau global state
	"""
	# Contoh: cek apakah zona permukaan sudah selesai
	# if GlobalProgress.zona_permukaan_completed:
	#     unlock_zona_tengah()
	# if GlobalProgress.zona_tengah_completed:
	#     unlock_zona_dasar()
	pass

func go_back():
	"""Kembali ke start screen"""
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")
