extends KinematicBody



enum MoveStates { STAND, WALK }

export var walk_speed : float = 0
export (NodePath) var navigation_node : String # This means `Navigation`, as in the actual `Navigation` node. Not `NavigationMeshInstance`!

onready var navigator : Navigation = get_node(navigation_node)

var path : PoolVector3Array = []
var path_index : int = 0
var move_state : int = MoveStates.STAND



# Functions you will need outside of this script

func change_state(new_state : int) -> void:
	var last_state : int = move_state
	move_state = new_state
	
	move_state_load(new_state)
	move_state_unload(last_state)



func move_to(target_pos : Vector3) -> void:
	path_index = 0
	create_path(target_pos)
	change_state(MoveStates.WALK)



func move_to_target(target : Spatial) -> void:
	path_index = 0
	create_path(target.global_transform.origin)
	change_state(MoveStates.WALK)



# Internal functions you shouldn't be using outside of this script

func _physics_process(_delta : float) -> void:
	move_state_machine()



func move_state_machine() -> void:
	match move_state:
		MoveStates.STAND:
			pass
		
		MoveStates.WALK:
			var direction : Vector3 = path[path_index] - global_transform.origin
			
			if direction.length() < 0.01 * walk_speed: # Multiplied by `walk_speed` so that it doesn't accidentally get stuck by overshooting target
				path_index += 1
			else:
				var _e = move_and_slide(direction.normalized() * walk_speed, Vector3.UP)
			
			if path_index == len(path):
				change_state(MoveStates.STAND)



func move_state_load(new_state : int) -> void:
	match new_state:
		MoveStates.STAND:
			pass
		
		MoveStates.WALK:
			pass



func move_state_unload(last_state : int) -> void:
	match last_state:
		MoveStates.STAND:
			pass
		
		MoveStates.WALK:
			pass



func create_path(target_pos : Vector3) -> void:
	path = navigator.get_simple_path(global_transform.origin, target_pos)
