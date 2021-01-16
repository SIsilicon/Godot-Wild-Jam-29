extends VBoxContainer



onready var prev_button : Button = $HBoxContainer/PreviousButton
onready var next_button : Button = $HBoxContainer/NextButton
onready var selection_label : Label = $HBoxContainer/Label
onready var label : Label = $Label

var setting : String
var options : PoolStringArray = []
var real_values : Array = []
var index : int = 0
var selection : String
var value

signal changed(wheel)



func set_text(text : String) -> void:
	yield(self, "ready")
	label.text = text



func set_setting(set_setting : String) -> void:
	yield(self, "ready")
	setting = set_setting



func set_options(set_options : PoolStringArray, set_real_values : Array) -> void:
	yield(self, "ready")
	options = set_options
	real_values = set_real_values



func set_index(set_index : int) -> void:
	yield(self, "ready")
	index = wrapi(set_index, 0, len(options))
	update_selection()



func update_selection() -> void:
	selection = options[index]
	value = real_values[index]
	selection_label.text = "%s) %s" % [index + 1, selection]
	emit_signal("changed", self)



func _on_NextButton_pressed() -> void:
	index = wrapi(index + 1, 0, len(options))
	update_selection()



func _on_PreviousButton_pressed() -> void:
	index = wrapi(index - 1, 0, len(options))
	update_selection()
