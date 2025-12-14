extends Control

# --------------------------------------------------------
# DATA SOAL
# --------------------------------------------------------
var soal = [
	{"img": "res://assets/Zona-Permukaan/anemon.png", "jawaban": "ANEMON"},
	{"img": "res://assets/Zona-Permukaan/bintang-laut.png", "jawaban": "BINTANGLAUT"},
	{"img": "res://assets/Zona-Permukaan/gurita.png", "jawaban": "GURITA"},
	{"img": "res://assets/Zona-Permukaan/hiu.png", "jawaban": "HIU"},
	{"img": "res://assets/Zona-Permukaan/kepiting.png", "jawaban": "KEPITING"},
	{"img": "res://assets/Zona-Permukaan/kuda-laut.png", "jawaban": "KUDALAUT"},
	{"img": "res://assets/Zona-Permukaan/lumba-lumba.png", "jawaban": "LUMBALUMBA"},
	{"img": "res://assets/Zona-Permukaan/makarel.png", "jawaban": "MAKAREL"},
	{"img": "res://assets/Zona-Permukaan/mantaray.png", "jawaban": "MANTARAY"},
	{"img": "res://assets/Zona-Permukaan/nemo.png", "jawaban": "NEMO"}
]

# --------------------------------------------------------
# NODE ONREADY
# --------------------------------------------------------
@onready var pertanyaan = $kotak_gambar/pertanyaan
@onready var huruf_pool = $huruf_pool
@onready var jawaban_box = $kotak_jawaban/HBoxContainer
@onready var submit_button = $TextureButton
@onready var sfx_benar = $SFXBenar
@onready var sfx_salah = $SFXSalah
@onready var bgm_victory = $BGMVictory
@onready var bgm_gameover = $BGMGameOver

# ========== TAMBAHAN UNTUK BACKGROUND MUSIC ==========
@onready var bgm_gameplay = $BGMGameplay  # AudioStreamPlayer untuk background music saat bermain
@onready var btn_mute = $btn_mute  # Button untuk mute
@onready var btn_music = $btn_music  # Button untuk unmute
# ====================================================

# ========== TAMBAHAN UNTUK SISTEM NYAWA (SPRITE2D) ==========
@onready var hati1 = $hati1  # Sprite2D untuk hati pertama
@onready var hati2 = $hati2  # Sprite2D untuk hati kedua
# ==========================================================

var index_soal := 0
var kata_jawaban := ""

var jumlah_benar := 0
var target_soal := 7
var jumlah_salah := 0
var max_salah := 2
var popup_menang_scene = preload("res://scenes/miniGames/popup_menang.tscn")
var popup_kalah_scene = preload("res://scenes/miniGames/popup_kalah.tscn")

var huruf_button_map := {}
var blur_overlay: ColorRect = null

# ========== VARIABEL UNTUK MUSIC STATE ==========
var is_music_muted := false
# ===============================================

# --------------------------------------------------------
func _ready():
	soal.shuffle()
	
	# Connect button submit
	if submit_button:
		submit_button.connect("pressed", Callable(self, "_on_submit_pressed"))
		# Connect animasi button press dan release
		submit_button.connect("button_down", Callable(self, "_on_submit_button_down"))
		submit_button.connect("button_up", Callable(self, "_on_submit_button_up"))
	
	# ========== CONNECT BUTTON MUTE & MUSIC ==========
	if btn_mute:
		btn_mute.connect("pressed", Callable(self, "_on_btn_mute_pressed"))
	if btn_music:
		btn_music.connect("pressed", Callable(self, "_on_btn_music_pressed"))
	
	# Setup awal tampilan button
	setup_music_buttons()
	# ================================================
	
	# ========== SETUP NYAWA AWAL ==========
	setup_nyawa()
	# =====================================
	
	# ========== PLAY BACKGROUND MUSIC ==========
	if bgm_gameplay:
		bgm_gameplay.volume_db = -10  # Volume background music (sesuaikan sesuai kebutuhan)
		bgm_gameplay.play()
	# ===========================================
	
	muat_soal()

# ========== SETUP TAMPILAN BUTTON MUSIC ==========
func setup_music_buttons():
	"""Setup tampilan awal button music berdasarkan state"""
	# Kedua button tetap visible, tapi salah satu disabled
	if is_music_muted:
		if btn_mute:
			btn_mute.disabled = true
			btn_mute.modulate = Color(0.5, 0.5, 0.5, 0.6)  # Buat lebih redup
		if btn_music:
			btn_music.disabled = false
			btn_music.modulate = Color(1, 1, 1, 1)  # Normal/terang
	else:
		if btn_mute:
			btn_mute.disabled = false
			btn_mute.modulate = Color(1, 1, 1, 1)  # Normal/terang
		if btn_music:
			btn_music.disabled = true
			btn_music.modulate = Color(0.5, 0.5, 0.5, 0.6)  # Buat lebih redup

# ========== SETUP NYAWA (SPRITE2D) ==========
func setup_nyawa():
	"""Setup tampilan awal nyawa (semua hati terlihat) menggunakan Sprite2D"""
	if hati1:
		hati1.visible = true
		hati1.modulate = Color(1, 1, 1, 1)  # Warna normal
		
	if hati2:
		hati2.visible = true
		hati2.modulate = Color(1, 1, 1, 1)  # Warna normal
		
	print("✅ Nyawa di-setup: 2 hati (Sprite2D)")

# ========== HILANGKAN SATU NYAWA ==========
func hilangkan_nyawa(nomor_kesalahan: int):
	"""Hilangkan hati berdasarkan nomor kesalahan dengan animasi (Sprite2D)"""
	var hati_target = null
	
	# Tentukan hati mana yang akan dihilangkan (dari kanan ke kiri)
	if nomor_kesalahan == 1:
		hati_target = hati2  # Kesalahan pertama: hati paling kanan hilang
	elif nomor_kesalahan == 2:
		hati_target = hati1  # Kesalahan kedua: hati paling kiri hilang
	
	if hati_target:
		# Animasi shake + fade out + scale down
		var tween = create_tween()
		tween.set_parallel(true)
		
		# Shake effect (getar kecil)
		var original_pos = hati_target.position
		tween.tween_property(hati_target, "position:x", original_pos.x + 10, 0.05)
		tween.chain().tween_property(hati_target, "position:x", original_pos.x - 10, 0.05)
		tween.chain().tween_property(hati_target, "position:x", original_pos.x, 0.05)
		
		# Fade out
		tween.tween_property(hati_target, "modulate:a", 0.0, 0.3).set_delay(0.15)
		
		# Scale down (mengecil sambil menghilang)
		var current_scale = hati_target.scale
		tween.tween_property(hati_target, "scale", Vector2(0, 0), 0.3).set_delay(0.15)
		
		await tween.finished
		hati_target.visible = false
		print("❤️ Hati ke-", nomor_kesalahan, " hilang!")
# ==========================================

# ========== HANDLER BUTTON MUTE ==========
func _on_btn_mute_pressed():
	"""Mute semua audio"""
	is_music_muted = true
	
	# Mute semua audio player
	if bgm_gameplay:
		bgm_gameplay.volume_db = -80
	if sfx_benar:
		sfx_benar.volume_db = -80
	if sfx_salah:
		sfx_salah.volume_db = -80
	if bgm_victory:
		bgm_victory.volume_db = -80
	if bgm_gameover:
		bgm_gameover.volume_db = -80
	
	# Update tampilan button - kedua tetap visible
	if btn_mute:
		btn_mute.disabled = true
		btn_mute.modulate = Color(0.5, 0.5, 0.5, 0.6)  # Redup
	if btn_music:
		btn_music.disabled = false
		btn_music.modulate = Color(1, 1, 1, 1)  # Terang
	
	print("Music dimute")

# ========== HANDLER BUTTON MUSIC ==========
func _on_btn_music_pressed():
	"""Unmute semua audio"""
	is_music_muted = false
	
	# Restore volume semua audio player
	if bgm_gameplay:
		bgm_gameplay.volume_db = -10  # Volume background music
	if sfx_benar:
		sfx_benar.volume_db = 0  # Volume SFX normal
	if sfx_salah:
		sfx_salah.volume_db = 0
	if bgm_victory:
		bgm_victory.volume_db = -5  # Volume victory music
	if bgm_gameover:
		bgm_gameover.volume_db = -5
	
	# Update tampilan button - kedua tetap visible
	if btn_mute:
		btn_mute.disabled = false
		btn_mute.modulate = Color(1, 1, 1, 1)  # Terang
	if btn_music:
		btn_music.disabled = true
		btn_music.modulate = Color(0.5, 0.5, 0.5, 0.6)  # Redup
	
	print("Music unmute")
# ============================================

# --------------------------------------------------------
func clear_children(node):
	for c in node.get_children():
		c.queue_free()

# --------------------------------------------------------
func generate_random_letters(jawaban: String, total_huruf := 26) -> Array:
	var result: Array = []
	var alphabet := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

	var counter := {}
	for c in jawaban:
		if c == " ": continue
		counter[c] = counter.get(c, 0) + 1

	for h in counter.keys():
		for x in range(counter[h]):
			result.append(h)

	while result.size() < total_huruf:
		result.append(alphabet[randi() % alphabet.length()])

	result.shuffle()
	return result

# --------------------------------------------------------
# MUAT SOAL BARU
# --------------------------------------------------------
func muat_soal():
	clear_children(huruf_pool)
	clear_children(jawaban_box)
	huruf_button_map.clear()

	huruf_pool.columns = 13
	huruf_pool.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	var data = soal[index_soal]
	kata_jawaban = data["jawaban"]

	# GAMBAR
	var tex = load(data["img"])
	if tex:
		pertanyaan.texture = tex
		pertanyaan.anchor_left = 0
		pertanyaan.anchor_top = 0
		pertanyaan.anchor_right = 1
		pertanyaan.anchor_bottom = 1
		pertanyaan.offset_left = 0
		pertanyaan.offset_top = 0
		pertanyaan.offset_right = 0
		pertanyaan.offset_bottom = 0
		pertanyaan.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		pertanyaan.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		pertanyaan.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		pertanyaan.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# KOTAK JAWABAN
	var panjang := kata_jawaban.length()
	var font_size := 40
	var cell_width := 60

	if panjang >= 12:
		font_size = 26
		cell_width = 40
	elif panjang >= 10:
		font_size = 30
		cell_width = 48
	elif panjang <= 5:
		font_size = 46
		cell_width = 70

	for i in range(panjang):
		var lbl = Label.new()
		lbl.text = "_"
		lbl.custom_minimum_size = Vector2(cell_width, 80)
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", font_size)
		
		lbl.mouse_filter = Control.MOUSE_FILTER_STOP
		lbl.gui_input.connect(_on_label_clicked.bind(lbl))
		
		jawaban_box.add_child(lbl)

	# Generate huruf acak
	var huruf_acak = generate_random_letters(kata_jawaban, 26)

	for h in huruf_acak:
		var btn = Button.new()
		btn.text = h
		btn.custom_minimum_size = Vector2(64, 64)
		btn.add_theme_font_size_override("font_size", 32)
		btn.connect("pressed", Callable(self, "_on_huruf_dipilih").bind(h, btn))
		huruf_pool.add_child(btn)

# --------------------------------------------------------
func _on_huruf_dipilih(huruf: String, tombol: Button):
	for lbl in jawaban_box.get_children():
		if lbl.text == "_":
			lbl.text = huruf
			tombol.disabled = true
			huruf_button_map[lbl] = tombol
			break

# --------------------------------------------------------
func _on_label_clicked(event: InputEvent, label: Label):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if label.text != "_":
			if label in huruf_button_map:
				var tombol = huruf_button_map[label]
				tombol.disabled = false
				huruf_button_map.erase(label)
			label.text = "_"

# --------------------------------------------------------
func _on_submit_pressed():
	print("Submit button diklik!")
	
	var sudah_lengkap = true
	for lbl in jawaban_box.get_children():
		if lbl.text == "_":
			sudah_lengkap = false
			break
	
	if not sudah_lengkap:
		print("Jawaban belum lengkap!")
		return
	
	periksa_jawaban()

# ========== ANIMASI BUTTON SUBMIT ==========
func _on_submit_button_down():
	"""Animasi saat button ditekan (scale down + rotate sedikit)"""
	if submit_button:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		
		# Scale down (mengecil sedikit)
		tween.tween_property(submit_button, "scale", Vector2(0.9, 0.9), 0.1)
		
		# Rotate sedikit (opsional, hapus jika tidak suka)
		tween.tween_property(submit_button, "rotation", deg_to_rad(-2), 0.1)

func _on_submit_button_up():
	"""Animasi saat button dilepas (kembali ke ukuran normal)"""
	if submit_button:
		var tween = create_tween()
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_ELASTIC)
		
		# Scale kembali normal dengan efek bounce
		tween.tween_property(submit_button, "scale", Vector2(1.0, 1.0), 0.3)
		
		# Rotation kembali normal
		tween.tween_property(submit_button, "rotation", 0.0, 0.3)
# ==========================================

# --------------------------------------------------------
func periksa_jawaban():
	var hasil := ""
	for lbl in jawaban_box.get_children():
		hasil += lbl.text

	if hasil == kata_jawaban:
		jumlah_benar += 1
		print("BENAR! Soal ke-", jumlah_benar, " dari ", target_soal)
		
		if sfx_benar and not is_music_muted:
			sfx_benar.play()
		
		if jumlah_benar >= target_soal:
			await get_tree().create_timer(0.8).timeout
			tampilkan_popup_menang()
			GlobalProgress.zona_permukaan_completed = true
			GlobalProgress.save()
			return
		
		await get_tree().create_timer(0.8).timeout
		index_soal += 1
		if index_soal >= soal.size():
			index_soal = 0
		muat_soal()
	else:
		jumlah_salah += 1
		print("SALAH! Kesalahan ke-", jumlah_salah, " dari ", max_salah)
		
		# Play SFX salah setiap kali salah menjawab
		if sfx_salah and not is_music_muted:
			sfx_salah.play()
		
		# ========== HILANGKAN NYAWA ==========
		hilangkan_nyawa(jumlah_salah)
		await get_tree().create_timer(0.5).timeout
		# ====================================
		
		if jumlah_salah >= max_salah:
			print("GAME OVER! Terlalu banyak kesalahan")
			# Tunggu sebentar sebelum tampilkan popup (SFX salah sudah diputar di atas)
			await get_tree().create_timer(0.5).timeout
			tampilkan_popup_kalah()
		else:
			print("Coba lagi! Sisa kesempatan: ", max_salah - jumlah_salah)
			reset_jawaban()

# --------------------------------------------------------
func reset_jawaban():
	for lbl in jawaban_box.get_children():
		if lbl.text != "_":
			if lbl in huruf_button_map:
				var tombol = huruf_button_map[lbl]
				tombol.disabled = false
				huruf_button_map.erase(lbl)
			lbl.text = "_"
	
	print("Jawaban direset. Silakan coba lagi!")

# --------------------------------------------------------
func tampilkan_popup_menang():
	print("SELAMAT! Anda telah menyelesaikan ", target_soal, " soal!")
	
	# ========== STOP BACKGROUND MUSIC & PLAY VICTORY ==========
	if bgm_gameplay:
		bgm_gameplay.stop()
	
	if bgm_victory and not is_music_muted:
		bgm_victory.play()
	# ==========================================================
	
	set_process_input(false)
	huruf_pool.mouse_filter = Control.MOUSE_FILTER_IGNORE
	jawaban_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for btn in huruf_pool.get_children():
		if btn is Button:
			btn.disabled = true
	
	if submit_button:
		submit_button.disabled = true
	
	blur_overlay = ColorRect.new()
	blur_overlay.color = Color(0, 0, 0, 0)
	blur_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	blur_overlay.anchor_left = 0
	blur_overlay.anchor_top = 0
	blur_overlay.anchor_right = 1
	blur_overlay.anchor_bottom = 1
	blur_overlay.offset_left = 0
	blur_overlay.offset_top = 0
	blur_overlay.offset_right = 0
	blur_overlay.offset_bottom = 0
	
	add_child(blur_overlay)
	
	var tween_blur = create_tween()
	tween_blur.tween_property(blur_overlay, "color", Color(0, 0, 0, 0.6), 0.4)
	
	await tween_blur.finished
	
	var popup = popup_menang_scene.instantiate()
	add_child(popup)
	
	if popup.has_signal("popup_closed"):
		popup.popup_closed.connect(_on_popup_closed)

func _on_popup_closed():
	print("Popup ditutup")
	
	# ========== STOP VICTORY MUSIC ==========
	if bgm_victory:
		bgm_victory.stop()
	# ========================================
	
	if blur_overlay:
		blur_overlay.queue_free()
		blur_overlay = null

# --------------------------------------------------------
func tampilkan_popup_kalah():
	print("GAME OVER! Anda telah melakukan ", max_salah, " kesalahan!")
	
	# ========== STOP BACKGROUND MUSIC ==========
	if bgm_gameplay:
		bgm_gameplay.stop()
	# ===========================================
	
	# SFX salah sudah diputar di periksa_jawaban(), jadi tidak perlu diputar lagi di sini
	# Langsung play BGM game over
	if bgm_gameover and not is_music_muted:
		bgm_gameover.play()
	
	set_process_input(false)
	huruf_pool.mouse_filter = Control.MOUSE_FILTER_IGNORE
	jawaban_box.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	for btn in huruf_pool.get_children():
		if btn is Button:
			btn.disabled = true
	
	if submit_button:
		submit_button.disabled = true
	
	blur_overlay = ColorRect.new()
	blur_overlay.color = Color(0, 0, 0, 0)
	blur_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	
	blur_overlay.anchor_left = 0
	blur_overlay.anchor_top = 0
	blur_overlay.anchor_right = 1
	blur_overlay.anchor_bottom = 1
	blur_overlay.offset_left = 0
	blur_overlay.offset_top = 0
	blur_overlay.offset_right = 0
	blur_overlay.offset_bottom = 0
	
	add_child(blur_overlay)
	
	var tween_blur = create_tween()
	tween_blur.tween_property(blur_overlay, "color", Color(0, 0, 0, 0.7), 0.4)
	
	await tween_blur.finished
	
	var popup = popup_kalah_scene.instantiate()
	add_child(popup)
	
	if popup.has_signal("popup_closed"):
		popup.popup_closed.connect(_on_popup_kalah_closed)

func _on_popup_kalah_closed():
	print("Popup kalah ditutup")
	
	if bgm_gameover and bgm_gameover.playing:
		bgm_gameover.stop()
	
	if blur_overlay:
		blur_overlay.queue_free()
		blur_overlay = null

# =========================================================
#                RESET GAME UNTUK COBA LAGI
# =========================================================
func reset_game():
	print("\n🔄 ========== RESET GAME DIPANGGIL ==========")

	# Hapus blur overlay jika masih ada
	if blur_overlay:
		print("✅ Menghapus blur overlay...")
		blur_overlay.queue_free()
		blur_overlay = null

	# Reset data permainan
	index_soal = 0
	jumlah_benar = 0
	jumlah_salah = 0
	print("✅ Data game direset (benar: 0, salah: 0)")

	# Kembalikan input
	set_process_input(true)
	print("✅ Input diaktifkan kembali")

	# RE-ENABLE MOUSE FILTER - INI PENTING!
	huruf_pool.mouse_filter = Control.MOUSE_FILTER_STOP
	jawaban_box.mouse_filter = Control.MOUSE_FILTER_STOP
	print("✅ Mouse filter diaktifkan kembali")

	# Aktifkan kembali semua button huruf
	for btn in huruf_pool.get_children():
		if btn is Button:
			btn.disabled = false
	print("✅ Button huruf diaktifkan")

	# Aktifkan kembali submit button
	if submit_button:
		submit_button.disabled = false
	print("✅ Submit button diaktifkan")

	# Stop semua music yang sedang playing
	if bgm_victory and bgm_victory.playing:
		bgm_victory.stop()
	if bgm_gameover and bgm_gameover.playing:
		bgm_gameover.stop()

	# Mainkan kembali musik gameplay jika tidak muted
	if bgm_gameplay and not is_music_muted:
		bgm_gameplay.play()
		print("✅ Background music dimainkan")

	# ========== RESET NYAWA ==========
	setup_nyawa()
	# ================================

	# Shuffle soal agar tidak sama
	soal.shuffle()
	print("✅ Soal di-shuffle")

	# Muat ulang soal pertama
	muat_soal()
	print("✅ Soal pertama dimuat")
	print("========== RESET SELESAI! ==========\n")
