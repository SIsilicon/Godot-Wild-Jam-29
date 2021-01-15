extends KinematicBody



onready var push_area : Area = $PushArea
onready var test_push_area : Area = $TestPushArea
onready var tween : Tween = $Tween
onready var mesh : MeshInstance = $object_cylinderpiece

export var push_speed : float = 0
export var do_camera : bool = true
export var gravity : float = 0



# Methods to be used inside and outside of script

func _ready() -> void:
	var material : SpatialMaterial = SpatialMaterial.new()
	material.albedo_texture = load("res://textures/puzzlestuff/cylinder_diffuse.png")
	mesh.set_surface_material(0, material)



func _physics_process(delta : float) -> void:
	if !is_on_floor(): tween.stop_all()
	move_and_slide(Vector3(0, -gravity, 0), Vector3.UP)



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
