extends Control

@onready var progress_fill = $CenterContainer/VBoxContainer/ProgressContainer/ProgressBarBG/ProgressBarFill
@onready var wave_animation = $CenterContainer/VBoxContainer/ProgressContainer/ProgressBarBG/WaveAnimation
@onready var percent_label = $CenterContainer/VBoxContainer/ProgressContainer/PercentLabel
@onready var loading_text = $CenterContainer/VBoxContainer/LoadingText

var progress: float = 0.0
var target_progress: float = 0.0
var loading_complete: bool = false
var next_scene: String = ""

# Wave animation
var wave_offset: float = 0.0
var wave_speed: float = 100.0

func _ready():
	progress_fill.size.x = 0
	wave_animation.size.x = 0
	
	# Start simulated loading
	simulate_loading()

func _process(delta):
	# Smooth progress animation
	if progress < target_progress:
		progress = move_toward(progress, target_progress, delta * 50.0)
		update_progress_bar()
	
	# Wave animation
	wave_offset += wave_speed * delta
	if wave_animation:
		wave_animation.position.x = fmod(wave_offset, 50.0) - 25.0
	
	# When loading complete, transition to next scene
	if loading_complete and progress >= 100.0:
		await get_tree().create_timer(0.5).timeout
		if next_scene != "":
			get_tree().change_scene_to_file(next_scene)
		else:
			get_tree().change_scene_to_file("res://scenes/start_screen.tscn")

func update_progress_bar():
	var container_width = $CenterContainer/VBoxContainer/ProgressContainer.size.x - 40
	var fill_width = (progress / 100.0) * container_width
	
	if progress_fill:
		progress_fill.size.x = fill_width
		progress_fill.custom_minimum_size.x = fill_width
	
	if wave_animation:
		wave_animation.size.x = fill_width
		wave_animation.custom_minimum_size.x = fill_width
	
	if percent_label:
		percent_label.text = str(int(progress)) + "%"
	
	# Update loading text
	if loading_text:
		var dots = int(progress / 10.0) % 4
		var dot_text = ".".repeat(dots)
		loading_text.text = "Loading" + dot_text

func simulate_loading():
	# Simulate resource loading with multiple stages
	await get_tree().create_timer(0.3).timeout
	target_progress = 20.0  # Loading assets
	
	await get_tree().create_timer(0.5).timeout
	target_progress = 45.0  # Loading scenes
	
	await get_tree().create_timer(0.4).timeout
	target_progress = 70.0  # Initializing
	
	await get_tree().create_timer(0.5).timeout
	target_progress = 90.0  # Finalizing
	
	await get_tree().create_timer(0.3).timeout
	target_progress = 100.0  # Complete
	loading_complete = true

func load_scene(scene_path: String):
	next_scene = scene_path
	simulate_loading()
