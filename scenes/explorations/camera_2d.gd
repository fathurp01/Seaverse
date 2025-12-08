extends Camera2D

var submarine = null
var locked_x = 0.0

# Offset camera (bisa diatur di Inspector)
@export var camera_offset_x: float = 0.0
@export var camera_offset_y: float = 0.0

# Limit kamera atas dan bawah (dalam pixel)
@export var camera_limit_top: float = 350.0  # Atur nilai ini sesuai kebutuhan
@export var camera_limit_bottom: float = 2900.0  # Atur nilai ini sesuai kebutuhan

func _ready():
	# Simpan posisi X awal
	locked_x = global_position.x
	
	# Set camera enabled & current
	enabled = true
	make_current()
	
	# Cari submarine
	await get_tree().process_frame
	submarine = get_tree().get_first_node_in_group("player")
	
	if submarine:
		print("✅ Camera found submarine!")
		print("   Camera limit top:", camera_limit_top)
		print("   Camera limit bottom:", camera_limit_bottom)
	else:
		print("❌ ERROR: Submarine not found!")

func _process(delta):
	if submarine:
		# Hitung posisi target kamera
		var target_y = submarine.global_position.y + camera_offset_y
		
		# Batasi posisi Y kamera agar tidak melewati limit atas dan bawah
		target_y = clamp(target_y, camera_limit_top, camera_limit_bottom)
		
		# Lock X, follow Y dengan offset dan limit
		global_position = Vector2(locked_x + camera_offset_x, target_y)
