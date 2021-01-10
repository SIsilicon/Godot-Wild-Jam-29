extends Spatial
class_name OutputDevice



enum States { INACTIVE, ACTIVE }
enum GateTypes { AND, OR }

export (GateTypes) var gate : int = GateTypes.AND
export (States) var state : int = States.INACTIVE

var input_devices : Array = []

signal toggled(state)



# Methods to be used outside/inside of script

func add_input_device(new_input_device) -> void:
	input_devices.append(new_input_device)



func remove_input_device(target_input_device) -> void:
	input_devices.erase(target_input_device)



# Methods to be used only inside of script

func update_state() -> void:
	match gate:
		GateTypes.AND:
			var locked : bool = false
			for input_device in input_devices:
				if input_device.state == InputDevice.States.DISABLED:
					locked = true
			
			if !locked:
				if state != States.ACTIVE: _on_enabled()
			else:
				if state != States.INACTIVE: _on_disabled()
		
		GateTypes.OR:
			var locked : bool = true
			for input_device in input_devices:
				if input_device.state == InputDevice.States.ENABLED:
					locked = false
			
			if !locked:
				if state != States.ACTIVE: _on_enabled()
			else:
				if state != States.INACTIVE: _on_disabled()


# Virtuals

func _on_enabled() -> void: pass
func _on_disabled() -> void: pass
