extends Area2D

# Path ke zona tujuan
@export_file("*.tscn") var next_zone_path: String = "res://scenes/miniGames/mini_game.tscn"

# Efek visual
@onready var sprite = $Sprite2D
@onready var anim_player = $AnimationPlayer

# Status
var is_player_inside = false

func _ready():
	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Play animasi
	if anim_player:
		anim_player.play("spin")

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered whirlpool!")
		is_player_inside = true
		# Pindah ke zona lain setelah delay
		await get_tree().create_timer(0.5).timeout
		if is_player_inside:
			change_zone()

func _on_body_exited(body):
	if body.is_in_group("player"):
		print("Player exited whirlpool")
		is_player_inside = false

func change_zone():
	print("Changing to zone: ", next_zone_path)
	get_tree().change_scene_to_file(next_zone_path)
