extends Area2D

@export var fish_name: String = "IKAN LELE"
@export var fish_description: String = "Ikan badut yang hidup di anemon laut"
@export var fish_fact: String = "Dapat hidup hingga kedalaman 15 meter"
@export var fish_sprite: Texture2D  # Untuk gambar sprite ikan
@export var fish_icon: Texture2D    # Untuk gambar icon di popup

var info_popup = null
var panel = null
var sprite = null
var icon_node = null

func _ready():
	# Dapatkan nodes
	info_popup = get_node_or_null("InfoPopup")
	panel = get_node_or_null("InfoPopup/Panel")
	sprite = get_node_or_null("Sprite2D")
	icon_node = get_node_or_null("InfoPopup/Panel/FishIcon")  # Node TextureRect untuk icon
	
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
	if info_popup:
		info_popup.visible = true

func hide_info():
	if info_popup:
		info_popup.visible = false
