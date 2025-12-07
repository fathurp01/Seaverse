extends CharacterBody2D

var speed = 200
var depth := 0

# Node references
@onready var anim_player = $AnimationPlayer
@onready var sprite = $Sprite2D
@onready var bubbles = $Bubbles

var surface_y := -2000

# === SISTEM FISIKA ===
var base_speed = 200.0
var current_speed = 200.0
var gravity_force = 150.0
var buoyancy_force = 50.0
var water_resistance = 0.95

# Pressure system
var pressure_start_depth = 350  # Mulai ada efek pressure di 350m
var max_pressure_depth = 400    # Full pressure di 400m
var min_speed_ratio = 0.3       # 30% speed di 400m+

# Momentum system
var acceleration = 500.0
var deceleration = 300.0
var current_velocity = Vector2.ZERO

func _ready():
	add_to_group("player")
	
	print("Bubbles node: ", bubbles)
	
	if anim_player:
		anim_player.play("idle_float")
	
	if bubbles:
		bubbles.emitting = false

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	calculate_pressure_effect()
	apply_physics(input, delta)
	
	velocity = current_velocity
	move_and_slide()
	
	animate_tilt(input)
	control_bubbles(input)

func _process(delta):
	depth = int((global_position.y - surface_y) / 10)
	update_depth_label()

func calculate_pressure_effect():
	var depth_meters = max(0, depth)
	
	# 0-350m: Kecepatan normal (100%)
	if depth_meters < pressure_start_depth:
		current_speed = base_speed
	# 350-400m: Kecepatan berkurang bertahap
	elif depth_meters < max_pressure_depth:
		var depth_range = max_pressure_depth - pressure_start_depth
		var depth_progress = depth_meters - pressure_start_depth
		var speed_reduction = (depth_progress / depth_range) * (1.0 - min_speed_ratio)
		current_speed = base_speed * (1.0 - speed_reduction)
	# 400m+: Kecepatan minimal (30%)
	else:
		current_speed = base_speed * min_speed_ratio

func apply_physics(input: Vector2, delta):
	var target_velocity = Vector2.ZERO
	
	if input != Vector2.ZERO:
		target_velocity = input.normalized()
		
		if input.y > 0:
			target_velocity.y *= (current_speed + gravity_force * (current_speed / base_speed))
		elif input.y < 0:
			target_velocity.y *= (current_speed - buoyancy_force * (current_speed / base_speed))
		
		target_velocity.x *= current_speed
		
		current_velocity = current_velocity.move_toward(target_velocity, acceleration * delta)
	else:
		current_velocity = current_velocity.move_toward(Vector2.ZERO, deceleration * delta)
	
	current_velocity *= water_resistance

func animate_tilt(input: Vector2):
	if sprite:
		var tilt_horizontal = input.x * 0.15
		var tilt_vertical = input.y * 0.1
		var target_rotation = tilt_horizontal + tilt_vertical
		
		if input.x != 0:
			sprite.flip_h = input.x > 0
		
		if sprite.flip_h:
			target_rotation = -target_rotation
		
		sprite.rotation = lerp(sprite.rotation, target_rotation, 0.1)

func control_bubbles(input: Vector2):
	if bubbles:
		bubbles.emitting = (input != Vector2.ZERO)
		
		var speed_ratio = current_velocity.length() / base_speed
		bubbles.amount = int(20 + speed_ratio * 30)
		
		if sprite.flip_h:
			bubbles.scale.x = -1
		else:
			bubbles.scale.x = 1

func update_depth_label():
	$DepthLabel.text = str(depth) + " M"
