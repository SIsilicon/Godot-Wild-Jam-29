extends HBoxContainer



onready var label : Label = $Label
onready var check_button : CheckButton = $CheckButton

var setting : String

signal toggled(button)



# Public methods

func set_text(text : String) -> void:
	yield(self, "ready")
	label.text = text



func set_state(enabled : bool) -> void:
	yield(self, "ready")
	check_button.pressed = enabled



func set_setting(set_setting : String) -> void:
	yield(self, "ready")
	setting = set_setting



func is_enabled() -> bool:
	return check_button.pressed



# Private methods

func _on_CheckButton_toggled(button_pressed):
	emit_signal("toggled", self)
