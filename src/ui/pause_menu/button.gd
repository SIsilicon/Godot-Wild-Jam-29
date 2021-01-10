extends Button
class_name PauseMenuButton



enum ButtonTypes { DEFAULT, RETURN, QUIT }

var button_type : int = ButtonTypes.DEFAULT
var opens_panel : Control = null
var return_button : bool = false

signal button_pressed(button)



func _init() -> void:
	var _e = connect("pressed", self, "button_pressed")



func button_pressed() -> void:
	emit_signal("button_pressed", self)
