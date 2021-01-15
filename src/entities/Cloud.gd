class_name Cloud
extends KinematicBody

var velocity: Vector3 = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	rotation += Vector3(
		rand_range(0, TAU),
		rand_range(0, TAU),
		rand_range(0, TAU)
	)

	
func _physics_process(delta):
	velocity = lerp(velocity, Vector3.ZERO, 0.02)
	move_and_slide(velocity)
	
	
func pull(direction: Vector3, pull_strength: int):
	
	var pull_direction = global_transform.origin.direction_to(direction)
	
	velocity = pull_direction * pull_strength
	
func shoot(push_direction: Vector3, shoot_speed: int):
	randomize()
	velocity = (push_direction + Vector3(rand_range(-0.1,0.1), rand_range(-0.1,0.1), 0)) * shoot_speed

