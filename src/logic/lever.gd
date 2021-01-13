extends InputDevice



onready var pivot : Spatial = $Pivot
onready var area : Area = $Area

export var handle_degrees : float = 0



# Methods not to be used outside of script

func _ready() -> void:
	update()



func _input(event : InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for body in area.get_overlapping_bodies():
			if body is Player:
				toggle()
				update()
				break



func update() -> void:
	match state:
		States.ENABLED:
			pivot.rotation_degrees.x = -handle_degrees
		
		States.DISABLED:
			pivot.rotation_degrees.x = handle_degrees
