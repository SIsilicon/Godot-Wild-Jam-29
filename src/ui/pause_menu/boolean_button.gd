extends HBoxContainer



onready var label : Label = $Label
onready var button : Button = $Button

var setting : String
var enabled : bool

signal toggled(button)



# Public methods

func set_text(text : String) -> void:
	yield(self, "ready")
	label.text = text



func set_state(enabled : bool) -> void:
	yield(self, "ready")
	#button.pressed = enabled
	enabled = Global.get_setting(setting)
	update()



func set_setting(set_setting : String) -> void:
	yield(self, "ready")
	setting = set_setting



func update() -> void:
	match enabled:
		true: button.text = "ON"
		false: button.text = "OFF"
	emit_signal("toggled", self)



# Private methods

func _on_Button_pressed():
	enabled = !enabled
	update()
