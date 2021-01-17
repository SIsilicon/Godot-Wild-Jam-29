extends Spatial
class_name InputDevice



enum States { DISABLED, ENABLED, STANDBY }

export (NodePath) var output_device_path : String

export var is_logic_NOT_gate: bool

var state : int = States.DISABLED

onready var output_device = get_node(output_device_path)

signal toggled



# Methods to be used outside of script

func toggle() -> void:
	state = wrapi(state + 1, States.DISABLED, States.STANDBY + 1)
	emit_signal("toggled")



func set_state(new_state : int) -> void:
	state = new_state
	
	match state:
		States.ENABLED:
			emit_signal("toggled")
		
		States.DISABLED:
			emit_signal("toggled")
			
		States.STANDBY:
			pass
			#emit_signal("toggled")



func _ready() -> void:
	if output_device != null:
		output_device.add_input_device(self)
		connect("toggled", output_device, "update_state")
	else:
		print("-----Untracked Output-----\nInput device:\n\tName: %s\n\tID: %s\n\nScene:\n\tName: %s\n-----Untracked Output-----" % [self.name, self, get_tree().current_scene.name])
