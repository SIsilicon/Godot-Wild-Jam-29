extends InputDevice



export var size : float
export var required_clouds : float = 1.0

onready var balloon : MeshInstance = $Balloon
onready var tween : Tween = $Tween

var clouds : Array = []

const MIN_BALLOON_SCALE : Vector3 = Vector3(0.1, 0.1, 0.1)
const MAX_BALLOON_SCALE : Vector3 = Vector3(1.0, 1.0, 1.0)





# Functions that should not be used outside of script

func _process(_delta) -> void:
	pull_clouds()



func _input(event) -> void:
	if event.is_action_pressed("ui_accept"):
		update_balloon()

func update_balloon() -> void:
	var target_scale : Vector3 = Vector3.ZERO
	var target_y : float = 0.0
	
	target_scale.x = clamp(size / max(required_clouds, 1.0), MIN_BALLOON_SCALE.x, MAX_BALLOON_SCALE.x)
	target_scale.y = clamp(size / max(required_clouds, 1.0), MIN_BALLOON_SCALE.y, MAX_BALLOON_SCALE.y)
	target_scale.z = clamp(size / max(required_clouds, 1.0), MIN_BALLOON_SCALE.z, MAX_BALLOON_SCALE.z)
	
	target_y = 0.5 + target_scale.y
	
	tween.stop_all()
	tween.interpolate_property(balloon, "scale", balloon.scale, target_scale, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(balloon, "translation:y", balloon.translation.y, target_y, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	if size == required_clouds:
		set_state(States.ENABLED)
	else:
		set_state(States.DISABLED)



func pull_clouds() -> void:
	for cloud in clouds:
		cloud.pull(global_transform.origin)
		
		if global_transform.origin.distance_to(cloud.global_transform.origin) < 0.5:
			clouds.erase(cloud)
			cloud.queue_free()
			size += 1
			update_balloon()



func _on_CloudPickup_body_entered(body : PhysicsBody) -> void:
	if body is Cloud:
		clouds.append(body)



func _on_CloudPickup_body_exited(body : PhysicsBody) -> void:
	if body is Cloud:
		clouds.erase(body)
