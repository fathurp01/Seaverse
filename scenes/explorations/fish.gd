extends Area2D

@export var fish_name: String = "IKAN LELE"
@export var fish_description: String = "Ikan badut yang hidup di anemon laut"
@export var fish_fact: String = "Dapat hidup hingga kedalaman 15 meter"
@export var fish_sprite: Texture2D  # Untuk gambar sprite ikan
@export var fish_icon: Texture2D    # Untuk gambar icon di popup
@export var popup_sound: AudioStream  # Audio saat popup muncul
@export var hide_sound: AudioStream   # Audio saat popup hilang (opsional)

# Variable untuk animasi
@export var fade_duration: float = 0.3  # Durasi fade dalam detik

var info_popup = null
var panel = null
var sprite = null
var icon_node = null
var audio_player = null  # Node untuk memutar audio
var tween: Tween  # Variable untuk menyimpan tween

func _ready():
	# Dapatkan nodes
	info_popup = get_node_or_null("InfoPopup")
	panel = get_node_or_null("InfoPopup/Panel")
	sprite = get_node_or_null("Sprite2D")
	icon_node = get_node_or_null("InfoPopup/Panel/FishIcon")  # Node TextureRect untuk icon
	audio_player = get_node_or_null("AudioStreamPlayer2D")  # Dapatkan audio player
	
	if info_popup == null:
		print("ERROR: InfoPopup tidak ditemukan!")
		return
	
	# Set gambar sprite ikan (kalau ada)
	if sprite and fish_sprite:
		sprite.texture = fish_sprite
	
	# Set gambar icon di popup (kalau ada)
	if icon_node and fish_icon:
		icon_node.texture = fish_icon
	
	# UPDATE TEXT LABEL DARI VARIABLE
	setup_labels()
	
	# Sembunyikan popup di awal
	info_popup.visible = false
	
	# Set state awal panel untuk animasi
	if panel:
		panel.modulate.a = 0  # Transparan
	
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	print("Fish ready: ", fish_name)

func setup_labels():
	# Cek dan update FishNameLabel
	var name_label = get_node_or_null("InfoPopup/Panel/VBoxContainer/FishNameLabel")
	if name_label:
		name_label.text = fish_name
	
	# Cek dan update FishDescLabel
	var desc_label = get_node_or_null("InfoPopup/Panel/VBoxContainer/FishDescLabel")
	if desc_label:
		desc_label.text = fish_description
	
	# Cek dan update FishFactLabel
	var fact_label = get_node_or_null("InfoPopup/Panel/VBoxContainer/FishFactLabel")
	if fact_label:
		fact_label.text = "⭐ " + fish_fact

func _on_body_entered(body):
	if body.is_in_group("player"):
		show_info()

func _on_body_exited(body):
	if body.is_in_group("player"):
		hide_info()

func show_info():
	play_sound(popup_sound)  # Mainkan audio popup
	fade_in()

func hide_info():
	play_sound(hide_sound)  # Mainkan audio hide (opsional)
	fade_out()

# ==========================================
# FUNGSI UNTUK MEMUTAR AUDIO
# ==========================================
func play_sound(sound: AudioStream):
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.play()

# ==========================================
# ANIMASI FADE IN
# ==========================================
func fade_in():
	if info_popup and panel:
		# Batalkan tween sebelumnya jika ada
		if tween:
			tween.kill()
		
		# Tampilkan popup
		info_popup.visible = true
		
		# Set alpha awal ke 0 (transparan)
		panel.modulate.a = 0
		
		# Buat tween baru
		tween = create_tween()
		
		# Animasi fade in - alpha dari 0 ke 1
		tween.tween_property(panel, "modulate:a", 1.0, fade_duration)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)

# ==========================================
# ANIMASI FADE OUT
# ==========================================
func fade_out():
	if info_popup and panel:
		# Batalkan tween sebelumnya jika ada
		if tween:
			tween.kill()
		
		# Buat tween baru untuk fade out
		tween = create_tween()
		
		# Animasi fade out - alpha dari 1 ke 0
		tween.tween_property(panel, "modulate:a", 0.0, fade_duration)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN)
		
		# Sembunyikan popup setelah animasi selesai
		tween.tween_callback(func(): info_popup.visible = false)
