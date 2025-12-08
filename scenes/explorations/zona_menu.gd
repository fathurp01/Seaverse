extends Control

# Node references untuk setiap zona
@onready var zona_permukaan = $ZonasContainer/ZonaPermukaan
@onready var zona_tengah = $ZonasContainer/ZonaTengah
@onready var zona_dasar = $ZonasContainer/ZonaDasar

# Status unlock untuk setiap zona (nanti bisa disimpan di global/save system)
var zona_permukaan_unlocked = true
var zona_tengah_unlocked = false
var zona_dasar_unlocked = false

# Border glow untuk setiap zona
var glow_permukaan: Panel
var glow_tengah: Panel
var glow_dasar: Panel

func _ready():
	# Pastikan musik opening tetap berjalan
	MusicManager.play_opening_music()
	
	# Buat border glow untuk setiap zona
	_create_glow_border(zona_permukaan, "glow_permukaan")
	_create_glow_border(zona_tengah, "glow_tengah")
	_create_glow_border(zona_dasar, "glow_dasar")
	
	# Set initial state untuk setiap zona
	_update_zona_states()

func _process(_delta):
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

func _create_glow_border(zona: Control, glow_name: String):
	"""Membuat border glow untuk zona"""
	var glow = Panel.new()
	glow.name = glow_name
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	# Setup size dan posisi border
	glow.layout_mode = 1
	glow.anchors_preset = Control.PRESET_FULL_RECT
	glow.anchor_left = 0
	glow.anchor_top = 0
	glow.anchor_right = 1
	glow.anchor_bottom = 1
	glow.offset_left = 0
	glow.offset_top = 0
	glow.offset_right = 0
	glow.offset_bottom = 0
	
	# Material untuk glow effect dengan border
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)  # Background transparan
	style.border_width_left = 4
	style.border_width_right = 4
	style.border_width_top = 4
	style.border_width_bottom = 4
	style.border_color = Color(0.3, 0.7, 1.0, 0)  # Cyan glow, alpha 0 (hidden)
	style.border_blend = true
	
	# Shadow untuk glow effect
	style.shadow_color = Color(0.3, 0.7, 1.0, 0)  # Cyan glow
	style.shadow_size = 20
	style.shadow_offset = Vector2(0, 0)
	
	glow.add_theme_stylebox_override("panel", style)
	
	# Hidden by default
	glow.modulate.a = 0
	
	# Tambahkan sebagai child zona (di layer paling atas)
	zona.add_child(glow)
	zona.move_child(glow, 0)  # Pindah ke belakang agar tidak menutupi konten
	
	# Simpan referensi
	if glow_name == "glow_permukaan":
		glow_permukaan = glow
	elif glow_name == "glow_tengah":
		glow_tengah = glow
	elif glow_name == "glow_dasar":
		glow_dasar = glow

# === ZONA PERMUKAAN HANDLERS ===
func _on_zona_permukaan_mouse_entered():
	if glow_permukaan:
		_animate_glow_in(glow_permukaan, zona_permukaan_unlocked)

func _on_zona_permukaan_mouse_exited():
	if glow_permukaan:
		_animate_glow_out(glow_permukaan)

func _on_zona_permukaan_pressed():
	if zona_permukaan_unlocked:
		print("Navigating to Zona Permukaan...")
		# Stop musik opening saat masuk eksplorasi
		MusicManager.stop_music()
		# Nanti ganti scene ke zona_permukaan.tscn
		get_tree().change_scene_to_file("res://scenes/explorations/zona_permukaan.tscn")

# === ZONA TENGAH HANDLERS ===
func _on_zona_tengah_mouse_entered():
	if glow_tengah:
		_animate_glow_in(glow_tengah, zona_tengah_unlocked)

func _on_zona_tengah_mouse_exited():
	if glow_tengah:
		_animate_glow_out(glow_tengah)

func _on_zona_tengah_pressed():
	if zona_tengah_unlocked:
		print("Navigating to Zona Tengah...")
		# Stop musik opening saat masuk eksplorasi
		MusicManager.stop_music()
		# Nanti ganti scene ke zona_tengah.tscn
		get_tree().change_scene_to_file("res://scenes/explorations/zona_tengah.tscn")

# === ZONA DASAR HANDLERS ===
func _on_zona_dasar_mouse_entered():
	if glow_dasar:
		_animate_glow_in(glow_dasar, zona_dasar_unlocked)

func _on_zona_dasar_mouse_exited():
	if glow_dasar:
		_animate_glow_out(glow_dasar)

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

func _animate_glow_in(glow: Panel, is_unlocked: bool):
	"""Animasi glow border muncul dengan efek pulsing"""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Fade in glow
	tween.tween_property(glow, "modulate:a", 1.0, 0.5)
	
	# Warna berbeda untuk locked dan unlocked
	var glow_color: Color
	if is_unlocked:
		glow_color = Color(0.3, 0.7, 1.0, 0.5)  # Cyan terang untuk unlocked (reduced alpha)
	else:
		glow_color = Color(0.5, 0.5, 0.5, 0.3)  # Abu-abu untuk locked (reduced alpha)
	
	var style = glow.get_theme_stylebox("panel") as StyleBoxFlat
	if style:
		style.border_color = glow_color
		style.shadow_color = glow_color

func _animate_glow_out(glow: Panel):
	"""Animasi glow border hilang"""
	var tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_SINE)
	
	# Fade out glow
	tween.tween_property(glow, "modulate:a", 0.0, 0.3)
