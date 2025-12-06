extends CharacterBody2D

var moved := false
var speed := 400
var depth := 1000

@onready var sub_cam = $SubCam

var surface_y := 470

func _ready():
	add_to_group("player")

func _physics_process(delta):
	var input_vec = Vector2.ZERO

	input_vec.x = Input.get_axis("ui_left", "ui_right")
	input_vec.y = Input.get_axis("ui_up", "ui_down")

	velocity = input_vec * speed
	move_and_slide()

	if input_vec != Vector2.ZERO and moved == false:
		switch_to_SubCam()
		moved = true

func _process(delta):

	var raw_depth = int(global_position.y / 10)

	depth = 1000 + raw_depth

	update_depth_label()



func switch_to_SubCam():
	sub_cam.make_current()

func update_depth_label():
	$DepthLabel_dasar.text = str(depth) + " M"
