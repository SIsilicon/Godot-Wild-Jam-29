extends Node

signal setting_changed(setting, value)

var base_window_size: Vector2

var settings := {
	invert_y = false,
	msaa = 0,
	window_size = [0, 0], # <- Not to be edited by user
	play_story = true, # <- Also not to be edited by user
	fullscreen = false,
	music_volume = 0.5,
	sfx_volume = 0.5
}

func _enter_tree() -> void:
	pause_mode = Node.PAUSE_MODE_PROCESS
	connect("setting_changed", self, "_on_setting_changed")
	
	load_settings()
	base_window_size = Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height")
	)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		set_setting("fullscreen", not OS.window_fullscreen)
		save_settings()


func save_settings() -> void:
	settings["window_size"] = [OS.window_size.x, OS.window_size.y]
	
	var file := File.new()
	file.open("user://settings.json", File.WRITE)
	file.store_line(to_json(settings))
	file.close()


func load_settings() -> void:
	var file := File.new()
	if file.file_exists("user://settings.json"):
		file.open("user://settings.json", File.READ)
		var loaded_settings: Dictionary = parse_json(file.get_line())
		for name in settings:
			if loaded_settings.has(name):
				settings[name] = loaded_settings[name]
			set_setting(name, settings[name])
		file.close()
	
	if settings["window_size"][0] != 0:
		OS.window_size.x = settings["window_size"][0]
		OS.window_size.y = settings["window_size"][1]


func set_setting(name: String, value) -> void:
	settings[name] = value
	emit_signal("setting_changed", name, value)


func get_setting(name: String, default := null):
	return settings.get(name, default)


func _on_setting_changed(name: String, value) -> void:
	match name:
		"window_size":
			if value[0] > 1 and value[1] > 1:
				OS.window_size.x = value[0]
				OS.window_size.y = value[1]
		"msaa":
			var root := get_tree().root
			root.msaa = value
		"fullscreen":
			OS.window_fullscreen = value
		"music_volume":
#			AudioServer.set_bus_volume_db(
#				AudioServer.get_bus_index("Music"),
#				linear2db(value)
#			)
			AudioManager.set_volume(
				AudioManager.Buses.MUSIC,
				value
			)
		"sfx_volume":
#			AudioServer.set_bus_volume_db(
#				AudioServer.get_bus_index("SFX"),
#				linear2db(value)
#			)
			AudioManager.set_volume(
				AudioManager.Buses.SFX,
				value
			)
			
			# Didn't realise AudioServer was a thing, so I sorta made my own
			# bus system you could say. Sorry, hadn't realised!
			# - Isaac/Glass
	save_settings()
