extends Node

# Sinyal untuk memberitahu perubahan platform
signal platform_changed(is_mobile: bool)

var is_mobile: bool = false
var is_touch_enabled: bool = false

func _ready():
	detect_platform()
	print("Platform detected - Mobile: ", is_mobile, " Touch: ", is_touch_enabled)

func detect_platform() -> void:
	# Deteksi berdasarkan OS
	var os_name = OS.get_name()
	
	# Check if running on mobile OS
	if os_name in ["Android", "iOS"]:
		is_mobile = true
		is_touch_enabled = true
	# Check if running on desktop but has touchscreen
	elif DisplayServer.is_touchscreen_available():
		is_mobile = true
		is_touch_enabled = true
	# Desktop tanpa touch
	else:
		is_mobile = false
		is_touch_enabled = false
	
	# Emit signal
	platform_changed.emit(is_mobile)

func get_is_mobile() -> bool:
	return is_mobile

func get_is_touch_enabled() -> bool:
	return is_touch_enabled

func force_mobile_mode(enabled: bool) -> void:
	is_mobile = enabled
	is_touch_enabled = enabled
	platform_changed.emit(is_mobile)
