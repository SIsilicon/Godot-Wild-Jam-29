extends InputDevice



export var size : float
export var required_clouds : float = 1000.0

onready var balloon : Spatial = $object_balloon
onready var base : MeshInstance = $object_cylinderpiece
onready var tween : Tween = $Tween

onready var light_bulb: LightBulb = $lightbulb

var clouds : Array = []

const MIN_BALLOON_SCALE : Vector3 = Vector3(0.1, 0.1, 0.1)
const MAX_BALLOON_SCALE : Vector3 = Vector3(1.0, 1.0, 1.0)





# Functions that should not be used outside of script

func _ready() -> void:
	var material : SpatialMaterial = SpatialMaterial.new()
	material.albedo_texture = load("res://textures/puzzlestuff/cylinder_diffuse.png")
	base.set_surface_material(0, material)
	
	balloon.get_node("AnimationPlayer").play("balloon_inflate")
	update_balloon()



func _process(_delta) -> void:
	if size < required_clouds: pull_clouds()



func update_balloon() -> void:
	var target_scale : Vector3 = Vector3.ZERO
	var target_y : float = 0.0
	
	target_scale.x = clamp(size / max(required_clouds, 1.0), MIN_BALLOON_SCALE.x, MAX_BALLOON_SCALE.x)
	target_scale.y = clamp(size / max(required_clouds, 1.0), MIN_BALLOON_SCALE.y, MAX_BALLOON_SCALE.y)
	target_scale.z = clamp(size / max(required_clouds, 1.0), MIN_BALLOON_SCALE.z, MAX_BALLOON_SCALE.z)
	
	target_y = 0.5
	
	tween.stop_all()
	tween.interpolate_property(balloon, "scale", balloon.scale, target_scale, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(balloon, "translation:y", balloon.translation.y, target_y, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	size = min(size, required_clouds)
	
	if size == required_clouds:
		set_state(States.ENABLED)
		light_bulb.turn_green()
		
	else:
		set_state(States.DISABLED)
		light_bulb.turn_red()



func pull_clouds() -> void:
	for cloud in clouds:
		cloud.pull(global_transform.origin, 10)
		
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
