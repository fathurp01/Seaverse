extends CanvasLayer

# Sinyal untuk input virtual
signal virtual_joystick_input(direction: Vector2)
signal action_button_pressed(action: String)

# Reference ke virtual joystick
@onready var joystick_base = $MobileControlsContainer/JoystickBase
@onready var joystick_tip = $MobileControlsContainer/JoystickBase/JoystickTip
@onready var action_buttons_container = $MobileControlsContainer/ActionButtons

# Joystick variables
var joystick_radius: float = 50.0
var joystick_center: Vector2 = Vector2.ZERO
var is_joystick_active: bool = false
var touch_index: int = -1

# Current input direction
var current_direction: Vector2 = Vector2.ZERO

# Platform detector
var platform_detector = null

func _ready():
	# Load platform detector
	platform_detector = load("res://scripts/platform_detector.gd").new()
	add_child(platform_detector)
	
	# Connect signal
	platform_detector.platform_changed.connect(_on_platform_changed)
	
	# Initial detection
	platform_detector.detect_platform()
	
	# Set initial visibility
	_update_visibility(platform_detector.is_mobile)
	
	if joystick_base:
		joystick_center = joystick_base.position + Vector2(joystick_radius, joystick_radius)

func _update_visibility(is_mobile: bool):
	# Hide atau show mobile controls
	if has_node("MobileControlsContainer"):
		$MobileControlsContainer.visible = is_mobile
		print("Mobile controls visibility: ", is_mobile)

func _on_platform_changed(is_mobile: bool):
	_update_visibility(is_mobile)

func _input(event):
	# Hanya proses jika mobile controls visible
	if not $MobileControlsContainer.visible:
		return
	
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch):
	var touch_pos = event.position
	
	# Check if touch is in joystick area
	var joystick_area = Rect2(joystick_base.global_position, Vector2(joystick_radius * 2, joystick_radius * 2))
	
	if event.pressed and joystick_area.has_point(touch_pos):
		# Start joystick
		is_joystick_active = true
		touch_index = event.index
		_update_joystick(touch_pos)
	elif not event.pressed and event.index == touch_index:
		# Release joystick
		is_joystick_active = false
		touch_index = -1
		_reset_joystick()

func _handle_drag(event: InputEventScreenDrag):
	if is_joystick_active and event.index == touch_index:
		_update_joystick(event.position)

func _update_joystick(touch_pos: Vector2):
	var joystick_global_center = joystick_base.global_position + Vector2(joystick_radius, joystick_radius)
	var direction = touch_pos - joystick_global_center
	
	# Limit to radius
	if direction.length() > joystick_radius:
		direction = direction.normalized() * joystick_radius
	
	# Update tip position
	joystick_tip.position = direction
	
	# Calculate normalized direction
	current_direction = direction / joystick_radius
	
	# Emit signal
	virtual_joystick_input.emit(current_direction)

func _reset_joystick():
	joystick_tip.position = Vector2.ZERO
	current_direction = Vector2.ZERO
	virtual_joystick_input.emit(Vector2.ZERO)

func get_joystick_direction() -> Vector2:
	return current_direction

func is_mobile_mode() -> bool:
	if platform_detector:
		return platform_detector.is_mobile
	return false
