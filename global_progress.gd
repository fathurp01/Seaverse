extends Node

var zona_permukaan_completed = false
var zona_tengah_completed = false
var zona_dasar_completed = false

func save():
	var data = {
		"zona_permukaan_completed": zona_permukaan_completed,
		"zona_tengah_completed": zona_tengah_completed,
		"zona_dasar_completed": zona_dasar_completed
	}
	
	var file = FileAccess.open("user://progress.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))

func load():
	if FileAccess.file_exists("user://progress.json"):
		var file = FileAccess.open("user://progress.json", FileAccess.READ)
		var data = JSON.parse_string(file.get_as_text())
		
		zona_permukaan_completed = data.get("zona_permukaan_completed", false)
		zona_tengah_completed = data.get("zona_tengah_completed", false)
		zona_dasar_completed = data.get("zona_dasar_completed", false)

func reset():
	"""Reset semua progress ke default (false)"""
	zona_permukaan_completed = false
	zona_tengah_completed = false
	zona_dasar_completed = false
	
	# Hapus file save jika ada
	if FileAccess.file_exists("user://progress.json"):
		DirAccess.remove_absolute("user://progress.json")
	
	print("Progress game telah direset!")
