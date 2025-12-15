extends Control

signal popup_closed

# Node references sesuai hierarchy
@onready var popup_container = $popup_menang
@onready var panel = $Panel
@onready var vbox_container = $popup_menang/VBoxContainer
@onready var btn_selesai = $popup_menang/btn_selesai  # Tombol selesai menggantikan kembali & lanjut
@onready var harta = $popup_menang/harta
@onready var label_berhasil = $popup_menang/VBoxContainer/Label
@onready var label_hadiah = $popup_menang/Label
@onready var zona = $popup_menang/zona

# Dictionary untuk gambar zona (sesuaikan dengan path gambar Anda)
var zona_images = {
	"zona_tengah": "res://scenes/miniGames/zona_tengah.png",
	"zona_dasar": "res://scenes/miniGames-ZonaDasar/popup_dasar_2.png"
}

# Variabel untuk menyimpan zona yang dipilih
var current_zona = "zona_tengah"  # Default zona

func _ready():
	# Koneksi tombol selesai
	if btn_selesai:
		btn_selesai.pressed.connect(_on_selesai_pressed)
	else:
		print("⚠️ Warning: Node 'btn_selesai' tidak ditemukan di path $popup_menang/btn_selesai")
	
	# Set gambar zona sesuai dengan zona yang didapat
	set_zona_image(current_zona)
	
	# Mulai animasi muncul
	show_popup()

func set_zona_image(zona_name: String):
	"""Set gambar zona berdasarkan nama zona"""
	if zona and zona_images.has(zona_name):
		var texture = load(zona_images[zona_name])
		if texture:
			zona.texture = texture
			print("✅ Zona diset ke: " + zona_name)
		else:
			print("⚠️ Gagal load texture: " + zona_images[zona_name])
	else:
		print("⚠️ Zona tidak ditemukan atau zona node null")

func show_popup():
	"""Tampilkan popup dengan animasi bounce yang dramatis"""
	visible = true
	
	# Karena popup_menang adalah CanvasLayer, kita animasi Panel sebagai gantinya
	if panel:
		# Setup state awal untuk Panel
		panel.scale = Vector2(0.3, 0.3)
		panel.modulate.a = 0.0
		panel.rotation = 0.0
		
		# Simpan posisi original
		var original_y = panel.position.y
		panel.position.y = original_y + 50
		
		# Buat tween dengan timing yang lebih baik
		var tween = create_tween()
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_OUT)
		
		# Animasi Scale dengan bounce
		tween.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.4)\
			.set_trans(Tween.TRANS_BACK)
		
		# Fade in
		tween.tween_property(panel, "modulate:a", 1.0, 0.3)
		
		# Posisi kembali normal
		tween.tween_property(panel, "position:y", original_y, 0.4)\
			.set_trans(Tween.TRANS_CUBIC)
		
		# Setelah bounce, kembali ke scale normal
		tween.chain()
		tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.15)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
	
	# Animasi elemen-elemen di dalam CanvasLayer
	_animate_popup_children()
	
	# Animasi wobble untuk harta karun
	await get_tree().create_timer(0.3).timeout
	if harta:
		_animate_treasure_wobble()
	
	# Animasi zona berputar muncul
	if zona:
		_animate_zona_appear()

func _animate_popup_children():
	"""Animasi untuk children dari CanvasLayer secara terpisah"""
	# Animasi VBoxContainer (tombol dan label)
	if vbox_container:
		vbox_container.modulate.a = 0.0
		vbox_container.scale = Vector2(0.8, 0.8)
		
		var vbox_tween = create_tween()
		vbox_tween.set_parallel(true)
		
		vbox_tween.tween_property(vbox_container, "modulate:a", 1.0, 0.4)\
			.set_delay(0.2)
		vbox_tween.tween_property(vbox_container, "scale", Vector2(1.0, 1.0), 0.3)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(0.2)
	
	# Animasi Label Hadiah
	if label_hadiah:
		label_hadiah.modulate.a = 0.0
		label_hadiah.position.y += 20
		
		var label_tween = create_tween()
		label_tween.set_parallel(true)
		
		var original_label_y = label_hadiah.position.y - 20
		label_tween.tween_property(label_hadiah, "modulate:a", 1.0, 0.3)\
			.set_delay(0.3)
		label_tween.tween_property(label_hadiah, "position:y", original_label_y, 0.3)\
			.set_trans(Tween.TRANS_BACK)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(0.3)
	
	# Animasi Harta
	if harta:
		harta.modulate.a = 0.0
		harta.scale = Vector2(0.5, 0.5)
		
		var harta_tween = create_tween()
		harta_tween.set_parallel(true)
		
		harta_tween.tween_property(harta, "modulate:a", 1.0, 0.4)\
			.set_delay(0.15)
		harta_tween.tween_property(harta, "scale", Vector2(1.0, 1.0), 0.5)\
			.set_trans(Tween.TRANS_ELASTIC)\
			.set_ease(Tween.EASE_OUT)\
			.set_delay(0.15)

func _animate_treasure_wobble():
	"""Animasi wobble halus untuk efek harta karun berkilau"""
	if not harta:
		return
	
	# Reset rotation dulu
	harta.rotation = 0.0
	
	var wobble_tween = create_tween()
	wobble_tween.set_loops()
	
	wobble_tween.tween_property(harta, "rotation", -0.03, 1.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	
	wobble_tween.tween_property(harta, "rotation", 0.03, 1.2)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)

func _animate_zona_appear():
	"""Animasi zona muncul dengan efek spin"""
	if not zona:
		return
	
	# Setup awal
	zona.scale = Vector2(0.2, 0.2)
	zona.rotation = -3.14  # 180 derajat
	zona.modulate.a = 0.0
	
	var zona_tween = create_tween()
	zona_tween.set_parallel(true)
	
	# Scale up dengan bounce
	zona_tween.tween_property(zona, "scale", Vector2(1.0, 1.0), 0.6)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
	
	# Rotate ke posisi normal
	zona_tween.tween_property(zona, "rotation", 0.0, 0.5)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
	
	# Fade in
	zona_tween.tween_property(zona, "modulate:a", 1.0, 0.4)

func hide_popup():
	"""Sembunyikan popup dengan animasi slide dan fade"""
	var tween = create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN)
	
	# Animasi Panel
	if panel:
		tween.tween_property(panel, "scale", Vector2(0.8, 0.8), 0.25)\
			.set_trans(Tween.TRANS_BACK)
		tween.tween_property(panel, "modulate:a", 0.0, 0.25)
		tween.tween_property(panel, "position:y", panel.position.y + 30, 0.25)\
			.set_trans(Tween.TRANS_CUBIC)
	
	# Animasi semua children di CanvasLayer
	if vbox_container:
		tween.tween_property(vbox_container, "modulate:a", 0.0, 0.2)
	if label_hadiah:
		tween.tween_property(label_hadiah, "modulate:a", 0.0, 0.2)
	if harta:
		tween.tween_property(harta, "modulate:a", 0.0, 0.2)
	if zona:
		tween.tween_property(zona, "modulate:a", 0.0, 0.2)
	
	# Tunggu animasi selesai
	await tween.finished
	emit_signal("popup_closed")
	queue_free()

func _on_selesai_pressed():
	"""Handler tombol selesai - kembali ke start screen"""
	print("✅ Selesai ditekan - Kembali ke start screen")
	
	# Animasi tombol ditekan
	_animate_button_press(btn_selesai)
	
	await hide_popup()
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func _animate_button_press(button: Control):
	"""Animasi feedback saat tombol ditekan"""
	if not button:
		return
	
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)

# ========== FUNGSI TAMBAHAN UNTUK MENGATUR ZONA ==========

func set_zona_by_level(level: int):
	"""Set zona berdasarkan level (1=dasar, 2=tengah)"""
	match level:
		1:
			set_zona_image("zona_dasar")
			current_zona = "zona_dasar"
		2:
			set_zona_image("zona_tengah")
			current_zona = "zona_tengah"
		_:
			print("⚠️ Level tidak valid: " + str(level))

func set_zona_by_name(zona_name: String):
	"""Set zona berdasarkan nama zona"""
	current_zona = zona_name
	set_zona_image(zona_name)
