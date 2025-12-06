extends CharacterBody2D

var moved := false
var speed = 200
var depth := 0

# Posisi Y permukaan laut
var surface_y := -2000

func _ready():
	add_to_group("player")

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	velocity = input * speed
	move_and_slide()
	
func _process(delta):
	# Hitung kedalaman berdasarkan posisi Y kapal selam terhadap permukaan laut
	depth = int((global_position.y - surface_y) / 10) # 10px = 1 meter
	update_depth_label()

func update_depth_label():
	$DepthLabel.text = str(depth) + " M"
