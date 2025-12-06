extends CharacterBody2D

var moved := false
var speed = 200
var depth := 0

@onready var sub_cam = $SubCamera

# Posisi Y permukaan laut
var surface_y := 470

func _ready():
	add_to_group("player")

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	velocity = input * speed
	move_and_slide()
	
	# Jika player mulai bergerak → pindah kamera
	if input != Vector2.ZERO and moved == false:
		switch_to_sub_camera()
		moved = true

func _process(delta):
	# Hitung kedalaman berdasarkan posisi Y kapal selam terhadap permukaan laut
	depth = int((global_position.y - surface_y) / 10) # 10px = 1 meter
	update_depth_label()

func switch_to_sub_camera():
	sub_cam.make_current()
	print("Camera switched to Submarine")

func update_depth_label():
	$DepthLabel.text = str(depth) + " M"
