extends KinematicBody



onready var push_area : Area = $PushArea
onready var test_push_area : Area = $TestPushArea
onready var tween : Tween = $Tween

export var push_speed : float = 0
export var do_camera : bool = true



# Methods to be used inside and outside of script

func push(direction : Vector3) -> void:
	direction *= 2
	
	test_push_area.translation = direction
	yield(get_tree().create_timer(0.02), "timeout") # HACK: somehow this fixes things idk
	var colliders : Array = test_push_area.get_overlapping_bodies()
	
	colliders.erase(self)
	
	var final : Vector3 = global_transform.origin
	
	if !colliders:
		final = test_push_area.global_transform.origin
	
	tween.stop_all()
	tween.interpolate_property(self, "global_transform:origin", global_transform.origin, final, push_speed)
	tween.start()
	
	yield(tween, "tween_completed")



func get_push_direction(pusher : Player) -> Vector3:
	var result : Vector3 = global_transform.origin - pusher.global_transform.origin
	result.y = 0
	result = result.normalized()
	
	return result



# Methods to not be used outside of script

func _input(event : InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for body in push_area.get_overlapping_bodies():
			if body is Player:
				push(get_push_direction(body))
				break
