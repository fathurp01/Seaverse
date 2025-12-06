extends Control

var button_explorasi: TextureButton
var original_scale: Vector2
var is_animating: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Connect ButtonExplorasi ke fungsi handler
	button_explorasi = $seaverse_animated_bg/ButtonExplorasi
	original_scale = button_explorasi.scale
	
	button_explorasi.pressed.connect(_on_button_explorasi_pressed)
	button_explorasi.mouse_entered.connect(_on_button_explorasi_hover)
	button_explorasi.mouse_exited.connect(_on_button_explorasi_unhover)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


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
	tween.tween_callback(func(): get_tree().change_scene_to_file("res://scenes/explorations/Zona_permukaan.tscn"))
