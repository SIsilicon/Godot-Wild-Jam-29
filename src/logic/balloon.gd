extends InputDevice



export var size : float
export var required_clouds : float = 1000.0

onready var balloon : Spatial = $object_balloon
onready var base : MeshInstance = $object_cylinderpiece
onready var cloud_pull_area: Area = $CloudPickup
onready var tween : Tween = $Tween
onready var cloud_spawn_point: Spatial = $CloudSpawnPoint
onready var light_bulb: LightBulb = $lightbulb

onready var spawn_cloud = preload("res://scenes/entities/TestCloud.tscn")


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
		
		if is_logic_NOT_gate:
			set_state(States.DISABLED)
			light_bulb.turn_red()
			
		else:
			set_state(States.ENABLED)
			light_bulb.turn_green()
			
	else:
		
		if is_logic_NOT_gate:
			set_state(States.ENABLED)
			light_bulb.turn_green()
			
		else:
			set_state(States.DISABLED)
			light_bulb.turn_red()
			


func pull_clouds() -> void:
	#clouds = cloud_pull_area.get_overlapping_bodies()
	
	
	for cloud in clouds:
		cloud.pull(global_transform.origin, 1)
		
		if global_transform.origin.distance_to(cloud.global_transform.origin) < 0.5:
			clouds.erase(cloud)
			cloud.queue_free()
			size += 1
			update_balloon()


func release_clouds(direction: Vector3) -> void:
	if size > 0:
		var cloud: Cloud = spawn_cloud.instance()
		
		get_parent().add_child(cloud)
		cloud.global_transform.origin = cloud_spawn_point.global_transform.origin
		cloud.shoot(cloud_spawn_point.global_transform.origin.direction_to(direction) , 15)
		size -= 1
		
	update_balloon()


func _on_CloudPickup_body_entered(body : PhysicsBody) -> void:
	if body is Cloud:
		clouds.append(body)



func _on_CloudPickup_body_exited(body : PhysicsBody) -> void:
	if body is Cloud:
		clouds.erase(body)
