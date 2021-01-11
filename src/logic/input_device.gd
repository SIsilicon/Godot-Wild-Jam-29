extends Node
class_name InputDevice



enum States { DISABLED, ENABLED }

export (NodePath) var output_device_path : String

var state : int = States.DISABLED

onready var output_device = get_node(output_device_path)

signal toggled



# Methods to be used outside of script

func toggle() -> void:
	state = wrapi(state + 1, States.DISABLED, States.ENABLED + 1)
	emit_signal("toggled")



func set_state(new_state : int) -> void:
	state = new_state
	emit_signal("toggled")



func _ready() -> void:
	output_device.add_input_device(self)
	connect("toggled", output_device, "update_state")
