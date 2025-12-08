extends Area2D

@export_file("*.tscn") var next_zone_path: String = "res://scenes/miniGames/mini_game.tscn"

# === PENGATURAN NOTIFIKASI ===
enum NotificationPosition {
	ABOVE_WHIRLPOOL,
	CENTER_TOP,
	CENTER_SCREEN,
	TOP_LEFT,
	TOP_RIGHT,
	BOTTOM_CENTER,
	CUSTOM
}

@export var notification_position: NotificationPosition = NotificationPosition.CENTER_TOP
@export var custom_notification_offset: Vector2 = Vector2(0, -150)  # Untuk CUSTOM position
@export var notification_text: String = "🌀 WHIRLPOOL MUNCUL!"
@export var notification_font_size: int = 32
@export var notification_color: Color = Color(0, 1, 1, 1)  # Cyan
@export var notification_duration: float = 2.0

# Efek visual
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

# Status
var is_player_inside = false
var is_unlocked = false

# Tracking ikan
var total_fish = 0
var discovered_fish = 0
var discovered_fish_names = []

func _ready():
	visible = false
	monitoring = false
	
	await get_tree().process_frame
	count_total_fish()
	connect_to_all_fish()
	
	print("Whirlpool: Total ikan yang harus ditemukan = ", total_fish)

func count_total_fish():
	var fish_nodes = get_tree().get_nodes_in_group("collectible_fish")
	total_fish = fish_nodes.size()

func connect_to_all_fish():
	var fish_nodes = get_tree().get_nodes_in_group("collectible_fish")
	for fish in fish_nodes:
		if fish.has_signal("fish_discovered"):
			fish.fish_discovered.connect(_on_fish_discovered)

func _on_fish_discovered(fish_name: String):
	discovered_fish += 1
	discovered_fish_names.append(fish_name)
	
	print("🐟 Progress: ", discovered_fish, "/", total_fish, " - ", fish_name)
	
	if discovered_fish >= total_fish:
		unlock_whirlpool()

func unlock_whirlpool():
	if is_unlocked:
		return
	
	is_unlocked = true
	print("🌀 WHIRLPOOL TERBUKA!")
	
	visible = true
	monitoring = true
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	if anim_player:
		anim_player.play("spin")
	
	modulate.a = 0
	var appear_tween = create_tween()
	appear_tween.tween_property(self, "modulate:a", 1.0, 1.0)
	
	show_unlock_notification()

func show_unlock_notification():
	var notification = Label.new()
	notification.text = notification_text
	notification.add_theme_font_size_override("font_size", notification_font_size)
	notification.modulate = notification_color
	notification.z_index = 100
	
	# Set horizontal alignment untuk center text
	notification.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notification.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Hitung posisi berdasarkan pilihan
	var notif_position = calculate_notification_position()
	notification.global_position = notif_position
	
	get_parent().add_child(notification)
	
	# Animasi notifikasi (ke atas dan fade out)
	var notif_tween = create_tween()
	notif_tween.tween_property(notification, "position:y", notification.position.y - 50, notification_duration)
	notif_tween.parallel().tween_property(notification, "modulate:a", 0.0, notification_duration)
	notif_tween.tween_callback(notification.queue_free)

func calculate_notification_position() -> Vector2:
	var viewport_size = get_viewport_rect().size
	var pos = Vector2.ZERO
	
	match notification_position:
		NotificationPosition.ABOVE_WHIRLPOOL:
			pos = global_position + custom_notification_offset
		
		NotificationPosition.CENTER_TOP:
			pos = Vector2(viewport_size.x / 2 - 150, 100)
		
		NotificationPosition.CENTER_SCREEN:
			pos = Vector2(viewport_size.x / 2 - 150, viewport_size.y / 2 - 50)
		
		NotificationPosition.TOP_LEFT:
			pos = Vector2(50, 50)
		
		NotificationPosition.TOP_RIGHT:
			pos = Vector2(viewport_size.x - 300, 50)
		
		NotificationPosition.BOTTOM_CENTER:
			pos = Vector2(viewport_size.x / 2 - 150, viewport_size.y - 100)
		
		NotificationPosition.CUSTOM:
			pos = global_position + custom_notification_offset
	
	return pos

func _on_body_entered(body):
	if not is_unlocked:
		return
	
	if body.is_in_group("player"):
		print("Player entered whirlpool!")
		is_player_inside = true
		
		show_transition_message()
		
		await get_tree().create_timer(1.0).timeout
		if is_player_inside:
			change_zone()

func _on_body_exited(body):
	if body.is_in_group("player"):
		print("Player exited whirlpool")
		is_player_inside = false

func show_transition_message():
	var message = Label.new()
	message.text = "Memasuki zona baru..."
	message.add_theme_font_size_override("font_size", 24)
	message.modulate = Color(1, 1, 1, 1)
	message.z_index = 100
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.global_position = global_position - Vector2(80, 100)
	
	get_parent().add_child(message)
	
	var msg_tween = create_tween()
	msg_tween.tween_property(message, "modulate:a", 0.0, 1.0)
	msg_tween.tween_callback(message.queue_free)

func change_zone():
	print("Changing to zone: ", next_zone_path)
	
	var fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.z_index = 1000
	get_tree().root.add_child(fade)
	
	var fade_tween = create_tween()
	fade_tween.tween_property(fade, "color:a", 1.0, 0.5)
	fade_tween.tween_callback(func(): get_tree().change_scene_to_file(next_zone_path))
