extends CanvasLayer

@onready var animated_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Dapatkan ukuran viewport
	var viewport_size = get_viewport().get_visible_rect().size
	
	# Set posisi sprite ke tengah viewport
	animated_sprite.position = viewport_size / 2
	
	# Hitung scale agar background memenuhi seluruh layar
	var sprite_size = animated_sprite.sprite_frames.get_frame_texture("default", 0).get_size()
	var scale_x = viewport_size.x / sprite_size.x
	var scale_y = viewport_size.y / sprite_size.y
	var scale_factor = max(scale_x, scale_y)
	
	animated_sprite.scale = Vector2(scale_factor, scale_factor)
	
	# Mulai animasi
	animated_sprite.play("default")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
