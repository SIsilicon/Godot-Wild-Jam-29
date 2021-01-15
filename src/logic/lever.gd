extends InputDevice



onready var lever : Spatial = $object_lever
onready var lever_anim : AnimationPlayer = $object_lever/AnimationPlayer
onready var area : Area = $Area



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
			lever_anim.play("lever_down")
		
		States.DISABLED:
			lever_anim.play("lever_up")
