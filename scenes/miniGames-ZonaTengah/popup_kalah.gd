extends Control

signal popup_closed

@onready var panel = $"../Panel"
@onready var vbox_container = $"../VBoxContainer"
@onready var tengkorak = $"../tengkorak"
@onready var label_info = $"../Label"
@onready var btn_coba_lagi = $"../btn_coba_lagi"
@onready var btn_eksplorasi_ulang = $"../btn_eksplorasi_ulang"

var mini_game_node = null


func _ready():
	print("\n=== POPUP KALAH READY ===")
	
	# Cari mini_game node
	mini_game_node = get_tree().get_first_node_in_group("mini_game")
	if mini_game_node:
		print("✅ Mini game node ditemukan!")
	else:
		print("❌ Mini game node TIDAK ditemukan!")
	
	# Connect buttons
	if btn_coba_lagi:
		print("✅ btn_coba_lagi ditemukan!")
		btn_coba_lagi.pressed.connect(_on_coba_lagi_pressed)
	else:
		print("❌ btn_coba_lagi TIDAK ditemukan!")
	
	if btn_eksplorasi_ulang:
		print("✅ btn_eksplorasi_ulang ditemukan!")
		btn_eksplorasi_ulang.pressed.connect(_on_eksplorasi_ulang_pressed)
	else:
		print("❌ btn_eksplorasi_ulang TIDAK ditemukan!")
	
	print("============================\n")
	
	show_popup()


# ==========================================================
#                ANIMASI POPUP
# ==========================================================

func show_popup():
	visible = true
	
	if panel:
		panel.scale = Vector2(0.3, 0.3)
		panel.modulate.a = 0.0
		panel.rotation = 0.0

		var original_y = panel.position.y
		panel.position.y = original_y - 30

		var tween = create_tween()
		tween.set_parallel(true)
		tween.set_ease(Tween.EASE_OUT)

		tween.tween_property(panel, "scale", Vector2(1.05, 1.05), 0.5).set_trans(Tween.TRANS_ELASTIC)
		tween.tween_property(panel, "modulate:a", 1.0, 0.4)
		tween.tween_property(panel, "position:y", original_y, 0.5).set_trans(Tween.TRANS_BOUNCE)

		tween.chain()
		tween.tween_property(panel, "scale", Vector2(1.0, 1.0), 0.2)

	_animate_popup_children()

	await get_tree().create_timer(0.4).timeout
	if tengkorak:
		_animate_skull_shake()


func _animate_popup_children():
	if vbox_container:
		vbox_container.modulate.a = 0.0
		vbox_container.scale = Vector2(0.8, 0.8)

		var vbox_tween = create_tween()
		vbox_tween.set_parallel(true)
		vbox_tween.tween_property(vbox_container, "modulate:a", 1.0, 0.5).set_delay(0.25)
		vbox_tween.tween_property(vbox_container, "scale", Vector2(1.0, 1.0), 0.4).set_delay(0.25)

	if label_info:
		label_info.modulate.a = 0.0
		label_info.position.y += 20

		var label_tween = create_tween()
		label_tween.set_parallel(true)
		var original_label_y = label_info.position.y - 20
		label_tween.tween_property(label_info, "modulate:a", 1.0, 0.3).set_delay(0.35)
		label_tween.tween_property(label_info, "position:y", original_label_y, 0.3).set_delay(0.35)

	if tengkorak:
		tengkorak.modulate.a = 0.0
		tengkorak.scale = Vector2(0.3, 0.3)
		tengkorak.rotation = -0.5

		var skull_tween = create_tween()
		skull_tween.set_parallel(true)
		skull_tween.tween_property(tengkorak, "modulate:a", 1.0, 0.5).set_delay(0.2)
		skull_tween.tween_property(tengkorak, "scale", Vector2(1.0, 1.0), 0.6).set_delay(0.2)
		skull_tween.tween_property(tengkorak, "rotation", 0.0, 0.5).set_delay(0.2)


func _animate_skull_shake():
	if not tengkorak:
		return

	var original_x = tengkorak.position.x
	var shake = create_tween()
	shake.set_loops()

	shake.tween_property(tengkorak, "position:x", original_x - 3, 0.1)
	shake.tween_property(tengkorak, "position:x", original_x + 3, 0.1)
	shake.tween_property(tengkorak, "position:x", original_x, 0.1)
	shake.tween_interval(2.0)


# ==========================================================
#                ANIMASI TUTUP POPUP
# ==========================================================

func hide_popup():
	var tween = create_tween()
	tween.set_parallel(true)

	if panel:
		tween.tween_property(panel, "scale", Vector2(0.7, 0.7), 0.3)
		tween.tween_property(panel, "modulate:a", 0.0, 0.3)
		tween.tween_property(panel, "position:y", panel.position.y + 40, 0.3)

	if vbox_container: tween.tween_property(vbox_container, "modulate:a", 0.0, 0.25)
	if label_info:      tween.tween_property(label_info, "modulate:a", 0.0, 0.25)
	if tengkorak:       tween.tween_property(tengkorak, "modulate:a", 0.0, 0.25)

	await tween.finished
	emit_signal("popup_closed")


# ==========================================================
#                TOMBOL COBA LAGI
# ==========================================================

func _on_coba_lagi_pressed():
	print("\n🔄 ========== COBA LAGI DIPENCET! ==========")
	
	# CARA PALING MUDAH: RELOAD SCENE MINI GAME
	print("♻️ Reload scene mini_game...")
	
	# Ambil path scene mini_game yang sedang aktif
	var current_scene = get_tree().current_scene
	var scene_path = current_scene.scene_file_path
	
	print("Scene path: ", scene_path)
	
	# Kalau tidak ada scene_path, coba cari manual
	if scene_path == "":
		# Ganti dengan path scene mini_game kamu
		scene_path = "res://scenes/miniGames/mini_game.tscn"
	
	# Reload scene
	get_tree().change_scene_to_file(scene_path)


# ==========================================================
#              TOMBOL EKSPLORASI ULANG
# ==========================================================

func _on_eksplorasi_ulang_pressed():
	print("\n🏠 ========== EKSPLORASI ULANG ==========")
	
	await hide_popup()
	await get_tree().create_timer(0.1).timeout

	get_tree().change_scene_to_file("res://scenes/start_screen.tscn")


# ==========================================================
#                ANIMASI TOMBOL
# ==========================================================

func _animate_button_press(button: Button):
	if not button:
		return
	
	var tween = create_tween()
	tween.tween_property(button, "scale", Vector2(0.9, 0.9), 0.1)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.1)
