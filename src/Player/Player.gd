extends KinematicBody



# StateMachine #
enum States {IDLE, RUNNING, JUMPING, FALLING, FLYING}
var state : int = States.IDLE

# Movement Variables #
const GRAVITY: int = -40
var velocity: Vector3= Vector3.ZERO
const MAX_SPEED: int = 25
const JUMP_SPEED: int = 20
const ACCELERATION: int = 6
const DEACCELERATION: int = 50
const MAX_SLOPE_ANGLE: int = 40
const FLYING_SPEED: int = 50
const HOVER_SPEED: int = 20

var input_movement_vector: Vector2
var direction := Vector3.ZERO
var hover_dir: Vector3


# Camera Variables #
onready var gimbal_x := $GimbalX
onready var gimbal_y := $GimbalX/GimbalY
onready var camera_position := $GimbalX/GimbalY/CameraPosition
const DEFAULT_ROTATION_SPEED: float = 0.2
const FLYING_ROTATION_SPEED: float = 0.2
var mouse_camera_sensitivity: float = 0.2
var look_dir: Vector3

onready var player_mesh: Spatial = $PlayerMesh
onready var goose: Spatial = $GoosePlaceholder



func _ready() -> void:
	
	# enable mouse to rotate camera
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# enter IDLE state at the beggining of the game
	enter_state(States.IDLE)


func enter_state(new_state):
	
	#change current state to new state
	state = new_state
	
	match state:
		
		States.IDLE:
			
			# TODO: Despawn goose glider
			goose.visible = false
			mouse_camera_sensitivity = DEFAULT_ROTATION_SPEED
			
			# TODO: Play idle animation
			pass
		
		
		States.RUNNING:
			# TODO: Play run animation
			pass
		
		
		States.JUMPING:
			
			# add velocity up to jump
			velocity.y = JUMP_SPEED
			
			# TODO: Play jumping animation
			
			
		States.FALLING:
			
			# TODO: Despawn goose glider
			goose.visible = false
			mouse_camera_sensitivity = DEFAULT_ROTATION_SPEED
			
			# TODO: Play falling animation
			
			
		States.FLYING:
			
			# TODO: Spawn goose glider
			goose.visible = true
			# TODO: Play flying animation
			
			# change camera rotation speed
			mouse_camera_sensitivity = FLYING_ROTATION_SPEED


func _input(event):
	
	# use mouse to rotate view
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		gimbal_x.rotate_y(deg2rad(-event.relative.x * mouse_camera_sensitivity))
		gimbal_y.rotate_x(deg2rad(-event.relative.y * mouse_camera_sensitivity))
		
		gimbal_y.rotation_degrees.x = clamp(gimbal_y.rotation_degrees.x, -75, 40)



func _physics_process(delta : float) -> void:
	process_input(delta)
	process_movement(delta)



func process_input(_delta : float) -> void:
	
	input_movement_vector = Vector2.ZERO
			
	input_movement_vector.y += int(Input.is_action_pressed("move_forward")) - int(Input.is_action_pressed("move_backward"))
	input_movement_vector.x += int(Input.is_action_pressed("move_right")) - int(Input.is_action_pressed("move_left"))
	
	match state:
	
	#### IDLE ####################################################################
		States.IDLE:
			input_movement_vector = input_movement_vector.normalized()
		#-----------------------------------------------------------------------
			# if player move then switch state to running
			if input_movement_vector != Vector2.ZERO:
				enter_state(States.RUNNING)
		#-----------------------------------------------------------------------
			
		#-----------------------------------------------------------------------
			# Jumping
			if is_on_floor():
				if Input.is_action_just_pressed("move_jump"):
					enter_state(States.JUMPING)
		#-----------------------------------------------------------------------
			
	#### RUNNING ###############################################################
		States.RUNNING:
			input_movement_vector = input_movement_vector.normalized()
		#-----------------------------------------------------------------------
			# if player don't move then switch state to idle
			if input_movement_vector == Vector2.ZERO:
				enter_state(States.IDLE)
		#-----------------------------------------------------------------------
			
		#-----------------------------------------------------------------------
			# move into direction relative to camera rotation
			direction = Vector3.ZERO
			var camera_xform = camera_position.get_global_transform()
			
			direction += -camera_xform.basis.z * input_movement_vector.y
			direction += camera_xform.basis.x * input_movement_vector.x
			
		
			# Rotate to match looking direction if moving
			if input_movement_vector != Vector2.ZERO:
				look_dir.x = lerp_angle(look_dir.x, direction.x, 0.1)
				look_dir.z = lerp_angle(look_dir.z, direction.z, 0.1)
			
				player_mesh.look_at(transform.origin + look_dir, Vector3.UP)
		#-----------------------------------------------------------------------
		
		#-----------------------------------------------------------------------
			# Jump if you are on the floor
			if is_on_floor():
				if Input.is_action_just_pressed("move_jump"):
					enter_state(States.JUMPING)
		#-----------------------------------------------------------------------
		
		
	#### JUMPING ###############################################################
		States.JUMPING:
			input_movement_vector = input_movement_vector.normalized()
		#-----------------------------------------------------------------------
			# move into direction relative to camera rotation
			direction = Vector3.ZERO
			var camera_xform = camera_position.get_global_transform()
			
			direction += -camera_xform.basis.z * input_movement_vector.y
			direction += camera_xform.basis.x * input_movement_vector.x
		#-----------------------------------------------------------------------
		
		#-----------------------------------------------------------------------
			# Start gliding/flying if you press jump while in air
			if Input.is_action_just_pressed("move_jump"):
					enter_state(States.FLYING)
		#-----------------------------------------------------------------------
	
	
	#### FALLING ###############################################################
		States.FALLING:
			input_movement_vector = input_movement_vector.normalized()
		#-----------------------------------------------------------------------
			# move into direction relative to camera rotation
			direction = Vector3.ZERO
			var camera_xform = camera_position.get_global_transform()
			
			direction += -camera_xform.basis.z * input_movement_vector.y
			direction += camera_xform.basis.x * input_movement_vector.x
		#-----------------------------------------------------------------------
		
		#-----------------------------------------------------------------------
			# Start gliding/flying if you press jump while in air
			if Input.is_action_just_pressed("move_jump"):
					enter_state(States.FLYING)
		#-----------------------------------------------------------------------
	
	
	#### FLYING ################################################################
		States.FLYING:
		#-----------------------------------------------------------------------
		# move into direction of camera
			#direction = Vector3.ZERO
			var camera_xform = camera_position.get_global_transform()
			var camera_forward = -camera_xform.basis.z
			var target_dir: Vector3 = Vector3.ZERO
			hover_dir = Vector3.ZERO
			
			target_dir = camera_forward
			hover_dir = camera_xform.basis.x * input_movement_vector.x
			
			
			direction = lerp(direction, target_dir, 0.05)
			
		
			# Rotate to match looking direction if moving
			look_dir.x = lerp_angle(look_dir.x, direction.x, 0.1)
			look_dir.z = lerp_angle(look_dir.z, direction.z, 0.1)
			
			player_mesh.look_at(global_transform.origin + look_dir, Vector3.UP)
			
			if input_movement_vector.y < 0:
				goose.look_at(goose.global_transform.origin + Vector3(direction.x, 0, direction.z), Vector3.UP)
				
			else:
				goose.look_at(goose.global_transform.origin + direction, Vector3.UP)
			
			# goose roll when turning
			var signed_angle = direction.cross(camera_forward).dot(Vector3.UP)
			goose.rotation_degrees.z = 60 * signed_angle
			
			# Cancel flying
			if Input.is_action_just_pressed("move_jump"):
					enter_state(States.FALLING)
		#-----------------------------------------------------------------------
	
	############################################################################
	
	
	
func process_movement(delta : float) -> void:
	
	match state:
		
	#############################################################################
		States.IDLE:
			
			velocity.y += GRAVITY * delta

			var new_velocity: Vector3
			new_velocity = new_velocity.linear_interpolate(velocity, DEACCELERATION * delta)
			
			velocity.x = new_velocity.x
			velocity.z = new_velocity.z
			
			velocity = move_and_slide(velocity, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
			
			if !is_on_floor():
				enter_state(States.FALLING)
	
	
	#############################################################################
		States.RUNNING:
			
			direction.y = 0
			direction = direction.normalized()
			
			velocity.y += GRAVITY * delta
			
			var new_velocity := velocity
			new_velocity.y = 0
			
			var target := direction
			target *= MAX_SPEED
			
			new_velocity = new_velocity.linear_interpolate(target, ACCELERATION * delta)
			velocity.x = new_velocity.x
			velocity.z = new_velocity.z
			velocity = move_and_slide(velocity, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
			
			if !is_on_floor():
				enter_state(States.FALLING)
	
	#############################################################################
		States.JUMPING:
			
			direction = direction.normalized()
			
			velocity.y += GRAVITY * delta
			
			var new_velocity := velocity
			
			var target := direction
			target *= MAX_SPEED
			
			new_velocity = new_velocity.linear_interpolate(target, 1 * delta)
			velocity.x = new_velocity.x
			velocity.z = new_velocity.z
			velocity = move_and_slide(velocity, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
			
			
			if is_on_floor():
				enter_state(States.IDLE)
		
	
	#### FALLING ###############################################################
		States.FALLING:
			
			direction = direction.normalized()
			
			velocity.y += GRAVITY * delta
			
			var new_velocity := velocity
			
			var target := direction
			target *= MAX_SPEED
			
			new_velocity = new_velocity.linear_interpolate(target, 1 * delta)
			velocity.x = new_velocity.x
			velocity.z = new_velocity.z
			velocity = move_and_slide(velocity, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
			
			if is_on_floor():
				enter_state(States.IDLE)
	
		
	#############################################################################
		States.FLYING:
			
			var target := direction
		
			
			target *= FLYING_SPEED * (1 + input_movement_vector.y)
			
			target += HOVER_SPEED * hover_dir
			
			velocity = lerp(velocity, target, 0.05)
			velocity = move_and_slide(velocity, Vector3.UP, 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))
			
			if is_on_floor():
				enter_state(States.IDLE)







