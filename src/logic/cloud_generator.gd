extends Spatial



export var max_cloud_count : int
export var cloud_spawn_interval : float
export var cloud_initial_speed : int

onready var timer : Timer = $Timer

var clouds : int = 0



func _ready() -> void:
	setup()



func setup() -> void:
	timer.wait_time = cloud_spawn_interval



func spawn_cloud() -> void:
	var cloud_packed : PackedScene = load("res://scenes/entities/TestCloud.tscn")
	var cloud : Cloud = cloud_packed.instance()
	
	cloud.connect("tree_exiting", self, "cloud_deleted")
	clouds += 1
	
	get_parent().add_child(cloud)
	cloud.global_transform.origin = global_transform.origin
	cloud.shoot(Vector3(randf(), randf(), randf()), cloud_initial_speed)



func _on_Timer_timeout() -> void:
	if clouds < max_cloud_count:
		spawn_cloud()



func cloud_deleted() -> void:
	clouds -= 1
