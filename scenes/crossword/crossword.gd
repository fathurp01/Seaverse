extends Control

@onready var grid_node = $Grid
@onready var animal_preview = $AnimalPreview

const GRID_SIZE := 12
const MAX_WORDS := 5

var grid: Array = []
var cell_to_word := {}
var selected_cells: Array = []  # Untuk tracking sel yang dipilih

# --- daftar kata hewan ---
var all_words := [
	"BLUESHARK",
	"EEL",
	"ISOPOD",
	"KEPITING",
	"LANTERNFISH",
	"PELAGIC",
	"SABERTOOTH",
	"SQUID",
	"TOMOPTERIS",
	"VIPERFISH"
]

var words: Array = []

# --- pasangkan kata dengan gambar ---
var word_image := {
	"BLUESHARK": preload("res://assets/Zona-Tengah/blue-shark.png"),
	"EEL": preload("res://assets/Zona-Tengah/eel.png"),
	"ISOPOD": preload("res://assets/Zona-Tengah/isopod.png"),
	"KEPITING": preload("res://assets/Zona-Tengah/kepiting.png"),
	"LANTERNFISH": preload("res://assets/Zona-Tengah/lanternifish.png"),
	"PELAGIC": preload("res://assets/Zona-Tengah/pelagic.png"),
	"SABERTOOTH": preload("res://assets/Zona-Tengah/sabertooth.png"),
	"SQUID": preload("res://assets/Zona-Tengah/squid.png"),
	"TOMOPTERIS": preload("res://assets/Zona-Tengah/tomopetris.png"),
	"VIPERFISH": preload("res://assets/Zona-Tengah/viperfish.png")
}

# Warna untuk highlight kata
var word_colors := [
	Color(0.4, 0.8, 0.4),  # Hijau
	Color(0.8, 0.4, 0.8),  # Pink/Ungu
	Color(0.4, 0.6, 1.0),  # Biru
	Color(1.0, 0.8, 0.4),  # Kuning/Orange
	Color(0.8, 0.5, 0.5),  # Merah muda
]

var word_to_color := {}

func _ready():
	randomize()
	select_random_words()
	assign_colors_to_words()
	generate_crossword()
	display_crossword()

func select_random_words():
	words.clear()
	var temp_words := all_words.duplicate()
	temp_words.shuffle()
	
	for i in range(min(MAX_WORDS, temp_words.size())):
		words.append(temp_words[i])

func assign_colors_to_words():
	word_to_color.clear()
	for i in range(words.size()):
		word_to_color[words[i]] = word_colors[i % word_colors.size()]

func generate_crossword():
	grid.clear()
	cell_to_word.clear()
	
	for y in range(GRID_SIZE):
		var row: Array = []
		for x in range(GRID_SIZE):
			row.append(".")
		grid.append(row)
	
	words.shuffle()
	place_first_word(words[0])
	
	for i in range(1, words.size()):
		place_word(words[i])

func place_first_word(word: String):
	var y := GRID_SIZE / 2
	var x_start := int((GRID_SIZE - word.length()) / 2)
	
	if x_start < 0:
		x_start = 0
	if x_start + word.length() > GRID_SIZE:
		x_start = GRID_SIZE - word.length()
	
	for i in range(word.length()):
		grid[y][x_start + i] = word[i]
		cell_to_word[Vector2i(x_start + i, y)] = word

func place_word(word: String):
	for attempt in range(300):
		var horizontal := (randi() % 2 == 0)
		var x := randi() % GRID_SIZE
		var y := randi() % GRID_SIZE
		
		if can_place(word, x, y, horizontal):
			do_place(word, x, y, horizontal)
			return

func can_place(word: String, x: int, y: int, h: bool) -> bool:
	if h:
		if x + word.length() > GRID_SIZE:
			return false
		for i in range(word.length()):
			var c: String = str(grid[y][x+i])
			if c != "." and c != word[i]:
				return false
	else:
		if y + word.length() > GRID_SIZE:
			return false
		for i in range(word.length()):
			var c: String = str(grid[y+i][x])
			if c != "." and c != word[i]:
				return false
	return true

func do_place(word: String, x: int, y: int, h: bool):
	if h:
		for i in range(word.length()):
			grid[y][x+i] = word[i]
			cell_to_word[Vector2i(x+i, y)] = word
	else:
		for i in range(word.length()):
			grid[y+i][x] = word[i]
			cell_to_word[Vector2i(x, y+i)] = word

func display_crossword():
	while grid_node.get_child_count() > 0:
		grid_node.get_child(0).queue_free()
	
	grid_node.columns = GRID_SIZE
	
	for y in range(GRID_SIZE):
		for x in range(GRID_SIZE):
			var char: String = str(grid[y][x])
			
			if char == ".":
				# Kotak hitam untuk sel kosong
				var block := ColorRect.new()
				block.color = Color(0.2, 0.2, 0.2)  # Abu-abu gelap
				block.custom_minimum_size = Vector2(45, 45)
				grid_node.add_child(block)
			else:
				# Button untuk sel dengan huruf
				var btn := Button.new()
				btn.text = char
				btn.custom_minimum_size = Vector2(45, 45)
				btn.set_meta("pos", Vector2i(x, y))
				btn.set_meta("char", char)
				
				# Style button agar mirip dengan gambar
				var style_normal := StyleBoxFlat.new()
				style_normal.bg_color = Color.WHITE
				style_normal.border_width_left = 1
				style_normal.border_width_right = 1
				style_normal.border_width_top = 1
				style_normal.border_width_bottom = 1
				style_normal.border_color = Color(0.3, 0.3, 0.3)
				
				var style_hover := StyleBoxFlat.new()
				style_hover.bg_color = Color(0.9, 0.9, 0.9)
				style_hover.border_width_left = 1
				style_hover.border_width_right = 1
				style_hover.border_width_top = 1
				style_hover.border_width_bottom = 1
				style_hover.border_color = Color(0.3, 0.3, 0.3)
				
				btn.add_theme_stylebox_override("normal", style_normal)
				btn.add_theme_stylebox_override("hover", style_hover)
				btn.add_theme_stylebox_override("pressed", style_hover)
				btn.add_theme_color_override("font_color", Color.BLACK)
				btn.add_theme_font_size_override("font_size", 20)
				
				btn.pressed.connect(cell_clicked.bind(btn))
				grid_node.add_child(btn)

func cell_clicked(btn: Button):
	var pos: Vector2i = btn.get_meta("pos")
	
	if pos in cell_to_word:
		var word: String = cell_to_word[pos]
		
		# Highlight seluruh kata
		highlight_word(word)
		
		# Tampilkan gambar hewan
		if word_image.has(word):
			animal_preview.texture = word_image[word]
		else:
			animal_preview.texture = null

func highlight_word(word: String):
	# Reset semua highlight sebelumnya
	reset_highlights()
	
	# Cari semua posisi dari kata ini
	var word_positions: Array = []
	for pos in cell_to_word.keys():
		if cell_to_word[pos] == word:
			word_positions.append(pos)
	
	# Highlight kata dengan warna
	var color: Color = word_to_color.get(word, Color(0.5, 0.8, 0.5))
	
	for pos in word_positions:
		var pos_vec: Vector2i = pos as Vector2i
		var index: int = pos_vec.y * GRID_SIZE + pos_vec.x
		if index < grid_node.get_child_count():
			var child: Node = grid_node.get_child(index)
			if child is Button:
				var style_highlight := StyleBoxFlat.new()
				style_highlight.bg_color = color
				style_highlight.border_width_left = 2
				style_highlight.border_width_right = 2
				style_highlight.border_width_top = 2
				style_highlight.border_width_bottom = 2
				style_highlight.border_color = color.darkened(0.3)
				
				child.add_theme_stylebox_override("normal", style_highlight)
				selected_cells.append(child)

func reset_highlights():
	# Reset semua sel yang di-highlight
	for cell in selected_cells:
		if cell is Button:
			var style_normal := StyleBoxFlat.new()
			style_normal.bg_color = Color.WHITE
			style_normal.border_width_left = 1
			style_normal.border_width_right = 1
			style_normal.border_width_top = 1
			style_normal.border_width_bottom = 1
			style_normal.border_color = Color(0.3, 0.3, 0.3)
			
			cell.add_theme_stylebox_override("normal", style_normal)
	
	selected_cells.clear()
