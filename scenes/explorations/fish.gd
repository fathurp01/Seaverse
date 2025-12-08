extends Area2D

@export var fish_name: String = "IKAN LELE"
@export var fish_description: String = "Ikan badut yang hidup di anemon laut"
@export var fish_fact: String = "Dapat hidup hingga kedalaman 15 meter"
@export var fish_sprite: Texture2D
@export var fish_icon: Texture2D
@export var popup_sound: AudioStream
@export var hide_sound: AudioStream

@export var fade_duration: float = 0.3

var info_popup = null
var panel = null
var sprite = null
var icon_node = null
var audio_player = null
var tween: Tween

# === SISTEM PENEMUAN IKAN ===
var is_discovered: bool = false  # Apakah ikan ini sudah ditemukan?
signal fish_discovered(fish_name: String)  # Signal saat ikan ditemukan

func _ready():
	# Tambahkan ke group "collectible_fish"
	add_to_group("collectible_fish")
	
	info_popup = get_node_or_null("InfoPopup")
	panel = get_node_or_null("InfoPopup/Panel")
	sprite = get_node_or_null("Sprite2D")
	icon_node = get_node_or_null("InfoPopup/Panel/FishIcon")
	audio_player = get_node_or_null("AudioStreamPlayer2D")
	
	if info_popup == null:
		print("ERROR: InfoPopup tidak ditemukan!")
		return
	
	if sprite and fish_sprite:
		sprite.texture = fish_sprite
	
	if icon_node and fish_icon:
		icon_node.texture = fish_icon
	
	setup_labels()
	info_popup.visible = false
	
	if panel:
		panel.modulate.a = 0
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	print("Fish ready: ", fish_name)

func setup_labels():
	var name_label = get_node_or_null("InfoPopup/Panel/VBoxContainer/FishNameLabel")
	if name_label:
		name_label.text = fish_name
	
	var desc_label = get_node_or_null("InfoPopup/Panel/VBoxContainer/FishDescLabel")
	if desc_label:
		desc_label.text = fish_description
	
	var fact_label = get_node_or_null("InfoPopup/Panel/VBoxContainer/FishFactLabel")
	if fact_label:
		fact_label.text = "⭐ " + fish_fact

func _on_body_entered(body):
	if body.is_in_group("player"):
		# Tandai ikan sebagai ditemukan saat pertama kali
		if not is_discovered:
			is_discovered = true
			fish_discovered.emit(fish_name)
			print("🐟 Ikan ditemukan: ", fish_name)
			
			# Opsional: Efek visual saat pertama kali ditemukan
			flash_sprite()
		
		show_info()

func _on_body_exited(body):
	if body.is_in_group("player"):
		hide_info()

func show_info():
	play_sound(popup_sound)
	fade_in()

func hide_info():
	play_sound(hide_sound)
	fade_out()

func play_sound(sound: AudioStream):
	if audio_player and sound:
		audio_player.stream = sound
		audio_player.play()

# === EFEK VISUAL SAAT DITEMUKAN ===
func flash_sprite():
	if sprite:
		var flash_tween = create_tween()
		flash_tween.tween_property(sprite, "modulate", Color(1.5, 1.5, 1.5, 1.0), 0.2)
		flash_tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.2)

func fade_in():
	if info_popup and panel:
		if tween:
			tween.kill()
		
		info_popup.visible = true
		panel.modulate.a = 0
		
		tween = create_tween()
		tween.tween_property(panel, "modulate:a", 1.0, fade_duration)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_OUT)

func fade_out():
	if info_popup and panel:
		if tween:
			tween.kill()
		
		tween = create_tween()
		tween.tween_property(panel, "modulate:a", 0.0, fade_duration)\
			.set_trans(Tween.TRANS_CUBIC)\
			.set_ease(Tween.EASE_IN)
		
		tween.tween_callback(func(): info_popup.visible = false)
