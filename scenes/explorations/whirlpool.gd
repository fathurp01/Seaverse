extends Area2D

@export_file("*.tscn") var next_zone_path: String = "res://scenes/miniGames/mini_game.tscn"
@export var notification_text: String = "🌀 WHIRLPOOL MUNCUL!"
@export var notification_font_size: int = 32
@export var notification_color: Color = Color(0, 1, 1, 1)
@export var notification_duration: float = 2.0
@export var fade_time: float = 0.5

# === PENGATURAN NOTIFIKASI POSISI (sederhana) ===
enum NotificationPosition {
	CENTER_TOP,
	ABOVE_WHIRLPOOL,
	CUSTOM
}
@export var notification_position: NotificationPosition = NotificationPosition.CENTER_TOP
@export var custom_notification_offset: Vector2 = Vector2(0, -150)

# Efek visual
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

# Status
var is_player_inside = false
var is_unlocked = false
var is_transitioning = false  # Flag untuk mencegah double transition

# Tracking ikan
var total_fish = 0
var discovered_fish = 0
var discovered_fish_names: Array = []

# Web export compatibility
var check_interval: float = 0.5  # Check setiap 0.5 detik
var time_since_check: float = 0.0
var is_ready: bool = false

func _ready():
	# default hidden / non-monitoring sampai unlocked
	visible = false
	monitoring = false

	# selalu connect signal body_entered/exited di _ready agar callback siap
	# tetapi monitoring akan tetap false sampai unlock_whirlpool()
	if not self.is_connected("body_entered", Callable(self, "_on_body_entered")):
		self.body_entered.connect(_on_body_entered)
	if not self.is_connected("body_exited", Callable(self, "_on_body_exited")):
		self.body_exited.connect(_on_body_exited)

	# tunggu lebih lama untuk web export
	await get_tree().create_timer(1.0).timeout

	count_total_fish()
	connect_to_all_fish()
	
	# Check status saat startup untuk web
	check_current_progress()
	
	is_ready = true

	print("Whirlpool: Total ikan yang harus ditemukan = ", total_fish)
	print("Whirlpool: Next zone path = ", next_zone_path)

func _process(delta):
	if not is_ready or is_unlocked:
		return
	
	# Polling system untuk web export - check progress berkala
	time_since_check += delta
	if time_since_check >= check_interval:
		time_since_check = 0.0
		check_current_progress()

func count_total_fish():
	var fish_nodes = get_tree().get_nodes_in_group("collectible_fish")
	total_fish = fish_nodes.size()

func connect_to_all_fish():
	var fish_nodes = get_tree().get_nodes_in_group("collectible_fish")
	print("Whirlpool: Connecting to ", fish_nodes.size(), " fish")
	for fish in fish_nodes:
		if fish.has_signal("fish_discovered"):
			# gunakan Callable supaya tidak duplicate connect
			var c = Callable(self, "_on_fish_discovered")
			if not fish.is_connected("fish_discovered", c):
				fish.fish_discovered.connect(c)
				print("Whirlpool: Connected to fish signal")

func check_current_progress():
	# Check fish yang sudah discovered (untuk web export)
	var fish_nodes = get_tree().get_nodes_in_group("collectible_fish")
	var current_count = 0
	
	for fish in fish_nodes:
		if fish.has_method("get") and fish.get("is_discovered"):
			current_count += 1
			if not discovered_fish_names.has(fish.fish_name):
				discovered_fish_names.append(fish.fish_name)
	
	# Update discovered count
	if current_count > discovered_fish:
		discovered_fish = current_count
		print("Whirlpool: Progress update: ", discovered_fish, "/", total_fish)
	
	# Auto unlock jika sudah semua
	if discovered_fish >= total_fish and total_fish > 0 and not is_unlocked:
		print("Whirlpool: All fish found! Unlocking...")
		unlock_whirlpool()

func _on_fish_discovered(fish_name: String) -> void:
	# Prevent duplicate counting
	if discovered_fish_names.has(fish_name):
		return
	
	discovered_fish += 1
	discovered_fish_names.append(fish_name)
	print("🐟 Progress: ", discovered_fish, "/", total_fish, " - ", fish_name)

	if discovered_fish >= total_fish and total_fish > 0:
		unlock_whirlpool()

func unlock_whirlpool():
	if is_unlocked:
		return
	is_unlocked = true
	print("🌀 WHIRLPOOL TERBUKA!")
	visible = true
	monitoring = true  # sekarang Area2D akan mendeteksi tubuh
	if anim_player:
		anim_player.play("spin")

	# fade-in tampilan whirlpool
	modulate.a = 0.0
	var t = create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.6)

	show_unlock_notification()

func show_unlock_notification():
	var notification = Label.new()
	notification.text = notification_text
	notification.add_theme_font_size_override("font_size", notification_font_size)
	notification.modulate = notification_color
	notification.z_index = 100
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# hitung posisi
	var pos = calculate_notification_position()
	notification.global_position = pos

	# tambahkan ke current_scene supaya Control positioning bekerja
	var root_control = get_tree().current_scene
	if root_control:
		root_control.add_child(notification)
	else:
		get_tree().root.add_child(notification) # fallback

	var notif_tween = create_tween()
	notif_tween.tween_property(notification, "position:y", notification.position.y - 50, notification_duration)
	notif_tween.parallel().tween_property(notification, "modulate:a", 0.0, notification_duration)
	notif_tween.tween_callback(notification.queue_free)

func calculate_notification_position() -> Vector2:
	var viewport_size = get_viewport_rect().size
	match notification_position:
		NotificationPosition.ABOVE_WHIRLPOOL:
			return global_position + custom_notification_offset
		NotificationPosition.CENTER_TOP:
			return Vector2(viewport_size.x / 2 - 150, 100)
		NotificationPosition.CUSTOM:
			return global_position + custom_notification_offset
		_:
			return Vector2(viewport_size.x / 2 - 150, 100)

func _on_body_entered(body) -> void:
	if not is_unlocked:
		print("Whirlpool belum unlocked!")
		return

	if is_transitioning:
		print("Sudah dalam proses transition!")
		return

	# pastikan body valid dan di group "player"
	if body and body.is_in_group("player"):
		print("✅ Player entered whirlpool!")
		print("✅ Next zone path: ", next_zone_path)
		is_player_inside = true
		is_transitioning = true
		# Gunakan call_deferred untuk web compatibility
		call_deferred("change_zone_immediate")

func _on_body_exited(body) -> void:
	if body and body.is_in_group("player"):
		print("Player exited whirlpool")
		is_player_inside = false
		# jangan reset is_transitioning di sini, biar tidak menggagalkan transition yang sedang berjalan

# Pindah scene LANGSUNG tanpa delay (dengan fade)
func change_zone_immediate() -> void:
	print("=== 🌀 MEMULAI TRANSISI ZONE ===")
	print("Path: ", next_zone_path)

	# Validasi path
	if next_zone_path == "":
		print("❌ ERROR: Path kosong!")
		is_transitioning = false
		return
	
	# Untuk web, skip file check karena bisa false negative
	var is_web = OS.has_feature("web")
	if not is_web and not FileAccess.file_exists(next_zone_path):
		print("❌ ERROR: File scene tidak ditemukan di path: ", next_zone_path)
		is_transitioning = false
		return

	# Preload scene untuk web compatibility
	var next_scene = load(next_zone_path)
	if next_scene == null:
		print("❌ ERROR: Gagal load scene: ", next_zone_path)
		is_transitioning = false
		return
	
	print("✅ Scene berhasil di-load")

	# buat ColorRect fade
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.z_index = 1000
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

	# Add ke root untuk web compatibility
	get_tree().root.add_child(fade)

	# tween fade to black
	var fade_tween = create_tween()
	fade_tween.tween_property(fade, "color:a", 1.0, fade_time)
	await fade_tween.finished

	print("✅ Fade selesai, pindah scene...")
	
	# Hapus fade sebelum pindah scene - PENTING untuk web!
	fade.queue_free()
	
	# Untuk web, gunakan change_scene_to_packed yang lebih reliable
	var err = get_tree().change_scene_to_packed(next_scene)
	if err != OK:
		print("❌ ERROR saat pindah scene! Error code: ", err)
		is_transitioning = false
		return
	
	print("✅ Scene transition complete!")

# Variasi: pindah dengan delay + pesan
func change_zone_with_delay() -> void:
	print("=== MEMULAI TRANSISI ZONE (WITH DELAY) ===")
	print("Path: ", next_zone_path)

	if next_zone_path == "" or not FileAccess.file_exists(next_zone_path):
		print("ERROR: File scene tidak ditemukan! Path: ", next_zone_path)
		is_transitioning = false
		return

	show_transition_message()
	await get_tree().create_timer(1.0).timeout

	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	if fade.has_method("set_anchors_and_offsets_preset"):
		fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.z_index = 1000
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var ui_parent = get_tree().current_scene
	if ui_parent:
		ui_parent.add_child(fade)
	else:
		get_tree().root.add_child(fade)

	var fade_tween = create_tween()
	fade_tween.tween_property(fade, "color:a", 1.0, fade_time)
	await fade_tween.finished

	print("Pindah scene sekarang...")
	var error = get_tree().change_scene_to_file(next_zone_path)
	if error != OK:
		print("ERROR: Gagal pindah scene! Code: ", error)
		fade.queue_free()
		is_transitioning = false

func show_transition_message():
	var message = Label.new()
	message.text = "Memasuki zona baru..."
	message.add_theme_font_size_override("font_size", 24)
	message.modulate = Color(1, 1, 1, 1)
	message.z_index = 100
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var viewport_size = get_viewport_rect().size
	message.global_position = Vector2(viewport_size.x / 2 - 100, viewport_size.y / 2)

	var ui_parent = get_tree().current_scene
	if ui_parent:
		ui_parent.add_child(message)
	else:
		get_tree().root.add_child(message)

	var msg_tween = create_tween()
	msg_tween.tween_property(message, "modulate:a", 0.0, 1.0)
	msg_tween.tween_callback(message.queue_free)
