class_name Cloud
extends KinematicBody

var velocity: Vector3 = Vector3.ZERO
const PULL_SPEED = 5
const SHOOT_SPEED = 20

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	velocity = lerp(velocity, Vector3.ZERO, 0.02)
	move_and_slide(velocity)
	
	
func pull(direction: Vector3):
	
	var pull_direction = global_transform.origin.direction_to(direction)
	
	velocity = pull_direction * PULL_SPEED
	
func shoot(push_direction: Vector3):
	
	velocity = push_direction * SHOOT_SPEED

