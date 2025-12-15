extends CanvasLayer

@onready var tutorial_panel = $TutorialPanel
@onready var btn_tutorial = $BtnTutorial
@onready var btn_tutup = $TutorialPanel/BtnTutup

func _ready():
	tutorial_panel.visible = false
	btn_tutorial.pressed.connect(_on_btn_tutorial_pressed)
	btn_tutup.pressed.connect(_on_btn_tutup_pressed)

func _on_btn_tutorial_pressed():
	tutorial_panel.visible = true
	get_tree().paused = true   # game pause

func _on_btn_tutup_pressed():
	tutorial_panel.visible = false
	get_tree().paused = false  # lanjut game
