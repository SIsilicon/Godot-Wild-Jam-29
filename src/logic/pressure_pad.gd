extends InputDevice



onready var pad_visual : Spatial = $object_pressureplate
onready var pad_animator : AnimationPlayer = $object_pressureplate/AnimationPlayer
onready var pad_timer: Timer = $PressurePlateTimer

var pushers : Array = []
var last_pusher_count : int = 0

export var pad_delay: int



# Private methods

func _ready() -> void:
	update_anim()



func update_pushers() -> void:
	if len(pushers) > 0:
		set_state(States.ENABLED)
		
	else:
		pad_timer.start(pad_delay)
		#set_state(States.DISABLED)
	
	update_anim()
	last_pusher_count = len(pushers)



func update_anim() -> void:
	if len(pushers) == 1:
		if len(pushers) > last_pusher_count:
			pad_animator.play("plate_in")
	elif len(pushers) == 0:
		pad_animator.play("plate_out")



func _on_PressureArea_body_entered(body : PhysicsBody) -> void:
	if body.is_in_group("pushes_pressure_pad"):
		pushers.append(body)
		update_pushers()



func _on_PressureArea_body_exited(body : PhysicsBody) -> void:
	if body.is_in_group("pushes_pressure_pad"):
		pushers.erase(body)
		update_pushers()


func _on_PressurePlateTimer_timeout():
	
	set_state(States.DISABLED)
	#update_anim()
	#last_pusher_count = len(pushers)
