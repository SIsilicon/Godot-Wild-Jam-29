extends Node

var base_window_size: Vector2

func _enter_tree() -> void:
	base_window_size = Vector2(
		ProjectSettings.get_setting("display/window/size/width"),
		ProjectSettings.get_setting("display/window/size/height")
	)
