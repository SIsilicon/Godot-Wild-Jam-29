extends VBoxContainer



onready var label : Label = $Label
onready var slider : HSlider = $HBoxContainer/HSlider
onready var slider_display_value : Label = $HBoxContainer/Label

var setting : String

signal value_changed(slider)



func set_text(text : String) -> void:
	yield(self, "ready")
	label.text = text



func set_value(value : float) -> void:
	yield(self, "ready")
	slider.value = value



func set_setting(setting : String) -> void:
	yield(self, "ready")
	setting = setting



func _on_HSlider_value_changed(value : float) -> void:
	slider_display_value.text = str(value * 100) + "%"
	emit_signal("value_changed", self)
