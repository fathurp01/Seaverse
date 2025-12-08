extends Control

var button_explorasi: TextureButton
var original_scale: Vector2
var is_animating: bool = false

# Button untuk kontrol musik
@onready var btn_mute = $seaverse_animated_bg/btn_mute
@onready var btn_music = $seaverse_animated_bg/btn_music

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Mulai memutar musik opening
	MusicManager.play_opening_music()
	
	# Connect ButtonExplorasi ke fungsi handler
	button_explorasi = $seaverse_animated_bg/ButtonExplorasi
	original_scale = button_explorasi.scale
	
	button_explorasi.pressed.connect(_on_button_explorasi_pressed)
	button_explorasi.mouse_entered.connect(_on_button_explorasi_hover)
	button_explorasi.mouse_exited.connect(_on_button_explorasi_unhover)
	
	# Connect button mute dan music
	if btn_mute:
		btn_mute.pressed.connect(_on_btn_mute_pressed)
	if btn_music:
		btn_music.pressed.connect(_on_btn_music_pressed)
	
	# Setup tampilan awal button
	_setup_music_buttons()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# Tombol ESC untuk exit game di start screen
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()


# Handler ketika mouse hover button
func _on_button_explorasi_hover() -> void:
	if not is_animating:
		# Animasi scale up sedikit (10% lebih besar)
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(button_explorasi, "scale", original_scale * 1.1, 0.3)


# Handler ketika mouse keluar dari button
func _on_button_explorasi_unhover() -> void:
	if not is_animating:
		# Kembalikan ke ukuran normal
		var tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(button_explorasi, "scale", original_scale, 0.3)


# Handler ketika ButtonExplorasi ditekan
func _on_button_explorasi_pressed() -> void:
	if is_animating:
		return
	
	is_animating = true
	
	# Animasi pop: scale down lalu scale up
	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
	
	# Scale down (efek tekan)
	tween.tween_property(button_explorasi, "scale", original_scale * 0.85, 0.1)
	# Scale up sedikit (efek bounce)
	tween.tween_property(button_explorasi, "scale", original_scale * 1.15, 0.15)
	# Kembali ke normal
	tween.tween_property(button_explorasi, "scale", original_scale, 0.1)
	
	# Pindah ke scene zone_menu setelah animasi selesai
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/explorations/zone_menu.tscn"))


# Setup tampilan button music
func _setup_music_buttons():
	"""Setup tampilan awal button music berdasarkan state dari MusicManager"""
	if MusicManager.is_muted:
		if btn_mute:
			btn_mute.disabled = true
			btn_mute.modulate = Color(0.5, 0.5, 0.5, 0.6)
		if btn_music:
			btn_music.disabled = false
			btn_music.modulate = Color(1, 1, 1, 1)
	else:
		if btn_mute:
			btn_mute.disabled = false
			btn_mute.modulate = Color(1, 1, 1, 1)
		if btn_music:
			btn_music.disabled = true
			btn_music.modulate = Color(0.5, 0.5, 0.5, 0.6)


# Handler button mute
func _on_btn_mute_pressed():
	"""Mute musik"""
	MusicManager.set_volume(-80)  # Mute dengan volume sangat rendah
	
	# Update tampilan button
	if btn_mute:
		btn_mute.disabled = true
		btn_mute.modulate = Color(0.5, 0.5, 0.5, 0.6)
	if btn_music:
		btn_music.disabled = false
		btn_music.modulate = Color(1, 1, 1, 1)
	
	print("Music dimute")


# Handler button music
func _on_btn_music_pressed():
	"""Unmute musik"""
	MusicManager.set_volume(0)  # Volume normal
	
	# Update tampilan button
	if btn_mute:
		btn_mute.disabled = false
		btn_mute.modulate = Color(1, 1, 1, 1)
	if btn_music:
		btn_music.disabled = true
		btn_music.modulate = Color(0.5, 0.5, 0.5, 0.6)
	
	print("Music unmute")
