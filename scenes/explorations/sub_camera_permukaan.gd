extends Camera2D

var submarine = null
var locked_x = 0.0
var camera_offset_y = 0.0  # Offset untuk center vertikal

# Limit kamera bawah (dalam pixel)
@export var camera_limit_bottom: float = 2875.0  # Atur nilai ini sesuai kebutuhan

func _ready():
	# Set camera enabled & current
	enabled = true
	make_current()
	
	# Cari submarine dulu
	await get_tree().process_frame
	submarine = get_tree().get_first_node_in_group("player")
	
	if submarine:
		# Lock X ke posisi submarine
		locked_x = submarine.global_position.x
		
		# Set offset Y agar submarine di tengah layar
		# Gunakan viewport height / 2 sebagai offset
		var viewport_height = get_viewport_rect().size.y
		camera_offset_y = 0  # Atau bisa diatur sesuai kebutuhan
		
		# Set posisi awal kamera
		global_position = Vector2(locked_x, submarine.global_position.y + camera_offset_y)
		
		print("✅ Camera locked to submarine X:", locked_x)
		print("   Viewport height:", viewport_height)
		print("   Camera limit bottom:", camera_limit_bottom)
	else:
		print("❌ ERROR: Submarine not found!")

func _process(delta):
	if submarine:
		# Offset untuk posisi kamera
		var offset_x = 640   # Geser kanan (+) atau kiri (-)
		var offset_y = 220 # Geser atas (-) atau bawah (+)
		
		# Hitung posisi target kamera
		var target_y = submarine.global_position.y + offset_y
		
		# Batasi posisi Y kamera agar tidak melewati limit bawah
		target_y = min(target_y, camera_limit_bottom)
		
		# Lock X dengan offset, follow Y dengan offset dan limit
		global_position = Vector2(locked_x + offset_x, target_y)
