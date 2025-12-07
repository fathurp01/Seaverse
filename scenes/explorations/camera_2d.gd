extends Camera2D

var submarine = null
var locked_x = 0.0

func _ready():
	# Simpan posisi X awal
	locked_x = global_position.x
	
	# Set camera enabled & current
	enabled = true
	make_current()
	
	# Cari submarine
	await get_tree().process_frame  # Tunggu 1 frame
	submarine = get_tree().get_first_node_in_group("player")
	
	if submarine:
		print("✅ Camera found submarine!")
	else:
		print("❌ ERROR: Submarine not found!")

func _process(delta):
	if submarine:
		# Lock X, follow Y
		global_position = Vector2(locked_x, submarine.global_position.y)
