extends Spatial
class_name OutputDevice



enum States { INACTIVE, ACTIVE }
enum GateTypes { AND, OR, NAND, NOR }

export (GateTypes) var gate : int = GateTypes.AND
export (States) var state : int = States.INACTIVE

var input_devices : Array = []

signal toggled(state)



# Methods to be used outside/inside of script

func enable() -> void:
	state = States.ACTIVE
	_on_enabled()



func disable() -> void:
	state = States.INACTIVE
	_on_disabled()



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
				if state != States.ACTIVE: enable()
			else:
				if state != States.INACTIVE: disable()
		
		GateTypes.OR:
			var locked : bool = true
			for input_device in input_devices:
				if input_device.state == InputDevice.States.ENABLED:
					locked = false
					break
			
			if !locked:
				if state != States.ACTIVE: enable()
			else:
				if state != States.INACTIVE: disable()
		
		GateTypes.NAND:
			var locked : bool = false
			var required : int = len(input_devices)
			var achieved : int = 0
			
			for input_device in input_devices:
				if input_device.state == InputDevice.States.ENABLED:
					achieved += 1
			
			if achieved == required:
				locked = true
			
			if !locked:
				if state != States.ACTIVE: enable()
			else:
				if state != States.INACTIVE: disable()
		
		GateTypes.NOR:
			var locked : bool = false
			
			for input_device in input_devices:
				if input_device.state == InputDevice.States.ENABLED:
					locked = true
					break
			
			if !locked:
				if state != States.ACTIVE: enable()
			else:
				if state != States.INACTIVE: disable()



# Virtuals

func _on_enabled() -> void: pass
func _on_disabled() -> void: pass
