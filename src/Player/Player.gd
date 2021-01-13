class_name Player
extends KinematicBody

# StateMachine #
enum States {IDLE, RUNNING, JUMPING, FALLING, FLYING, STEERING}
var state : int = States.IDLE

# Movement Variables #
const GRAVITY: int = -40
var velocity: Vector3= Vector3.ZERO
const MAX_SPEED: int = 15
const JUMP_SPEED: int = 15
const ACCELERATION: int = 6
const DEACCELERATION: int = 25
const MAX_SLOPE_ANGLE: int = 40
const FLYING_SPEED: int = 15
const HOVER_SPEED: int = 10

var input_movement_vector: Vector2
var direction := Vector3.ZERO
var hover_dir: Vector3

export var YaxisInversion_ON: bool = false
var Y_axis_inverter: int = 0

# Camera Variables #
onready var gimbal_x := $GimbalX
onready var gimbal_y := $GimbalX/GimbalY
onready var camera_position := $GimbalX/GimbalY/CameraPosition
const DEFAULT_ROTATION_SPEED: float = 0.2
const FLYING_ROTATION_SPEED: float = 0.2
var mouse_camera_sensitivity: float = 0.2
var look_dir: Vector3

onready var player_mesh: Spatial = $PlayerMesh
onready var character_anim_player: AnimationPlayer = $PlayerMesh/AnimationPlayer
onready var goose_anim_player: AnimationPlayer = $Goose_fixed/AnimationPlayer
onready var vacuum_anim_player: AnimationPlayer = $PlayerMesh/Armature/Skeleton/BoneAttachment/CloudCollector/AnimationPlayer
onready var goose: Spatial = $Goose_fixed

# Cloud collector #
onready var vacuum_muzzle: Area = $PlayerMesh/PullingArea
onready var spawn_cloud = preload("res://scenes/entities/TestCloud.tscn")

var isVacuumON: bool = false
var isSucking: bool = false
var isShooting: bool = false
var pull_strength: int = 5
var shoot_speed: int = 20

const DEFAULT_PULL_STR = 5
const FLYING_PULL_STR = 20
const DEFAULT_SHOOT_SPEED = 20
const FLYING_SHOOT_SPEED = 60


func _ready() -> void:
	
	# enable mouse to rotate camera
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	# enter IDLE state at the beggining of the game
	enter_state(States.IDLE)
	vacuum_play_animation("OFF")


func enter_state(new_state) -> void:
	
	#change current state to new state
	state = new_state
	
	match state:
		
		States.IDLE:
			play_animation("Idle")
			
			# TODO: Despawn goose glider
			goose.visible = false
			mouse_camera_sensitivity = DEFAULT_ROTATION_SPEED
			
			pull_strength = DEFAULT_PULL_STR
			shoot_speed = DEFAULT_SHOOT_SPEED
			Y_axis_inverter = 1
		
		States.RUNNING:
			play_animation("Run")
			
			pull_strength = DEFAULT_PULL_STR
			shoot_speed = DEFAULT_SHOOT_SPEED
			Y_axis_inverter = 1
		
		States.JUMPING:
			play_animation("Jump")
			# add velocity up to jump
			velocity.y += JUMP_SPEED
			
			pull_strength = DEFAULT_PULL_STR
			shoot_speed = DEFAULT_SHOOT_SPEED
			Y_axis_inverter = 1
		
		States.FALLING:
			play_animation("Fall")
			# TODO: Despawn goose glider
			goose.visible = false
			mouse_camera_sensitivity = DEFAULT_ROTATION_SPEED
			
			pull_strength = DEFAULT_PULL_STR
			shoot_speed = DEFAULT_SHOOT_SPEED
			Y_axis_inverter = 1
		
		States.FLYING:
			play_animation("Flying")
			# TODO: Spawn goose glider
			goose.visible = true
			
			# change camera rotation speed
			mouse_camera_sensitivity = FLYING_ROTATION_SPEED
			
			pull_strength = FLYING_PULL_STR
			shoot_speed = FLYING_SHOOT_SPEED
			
			if YaxisInversion_ON:
				Y_axis_inverter = -1
			else:
				Y_axis_inverter = 1
		
		States.STEERING:
			# TODO: Add animation for steering
			Y_axis_inverter = 1
	
	shape_owner_set_disabled(get_shape_owners()[0], state == States.STEERING)


func _input(event: InputEvent) -> void:
	# use mouse to rotate view
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		gimbal_x.rotate_y(deg2rad(-event.relative.x * mouse_camera_sensitivity))
		gimbal_y.rotate_x(deg2rad(-event.relative.y * mouse_camera_sensitivity * Y_axis_inverter))
		
		gimbal_y.rotation_degrees.x = clamp(gimbal_y.rotation_degrees.x, -75, 40)

	# VACUUM ON/OFF #
	if event is InputEventMouseButton:
		match event.button_index:
			
			1: # LMB
				if event.is_pressed():
					vacuum_play_animation("ON")
					isShooting = true
					isSucking = false
					
				else:
					vacuum_play_animation("OFF")
					isShooting = false
			
			2: # RMB
				if event.is_pressed():
					vacuum_play_animation("ON")
					isShooting = false
					isSucking = true
					
				else:
					vacuum_play_animation("OFF")
					isSucking = false


func _physics_process(delta: float) -> void:
	process_input(delta)
	process_movement(delta)
	process_actions(delta)


func process_input(_delta: float) -> void:
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
				look_dir.x = lerp_angle(look_dir.x, direction.x, 0.2)
				look_dir.z = lerp_angle(look_dir.z, direction.z, 0.2)
				
				player_mesh.look_at(player_mesh.global_transform.origin + look_dir, Vector3.UP)
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
			#look_dir.x = lerp_angle(look_dir.x, direction.x, 0.1)
			#look_dir.z = lerp_angle(look_dir.z, direction.z, 0.1)
			
			
			
			if input_movement_vector.y < 0:
				goose.look_at(goose.global_transform.origin + Vector3(direction.x, 0, direction.z), Vector3.UP)
				player_mesh.look_at(player_mesh.global_transform.origin + + Vector3(direction.x, 0, direction.z), Vector3.UP)
				goose_play_animation("Hover")
				
			else:
				goose.look_at(goose.global_transform.origin + direction, Vector3.UP)
				player_mesh.look_at(player_mesh.global_transform.origin + direction, Vector3.UP)
				
				if direction.y > 0:
					goose_play_animation("Fly")
				
				else:
					goose_play_animation("Glide")
			
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


func process_actions(_delta: float) -> void:
	if isSucking:
		pull_clouds()
		
	if isShooting:
		shoot_clouds()


func turn_on_vacuum():
	pass


func pull_clouds() -> void:
	
	var clouds_in_area = vacuum_muzzle.get_overlapping_bodies()
	
	if clouds_in_area.size() > 0:
		for cloud in clouds_in_area:
			if cloud.has_method("pull"):
				cloud.pull(vacuum_muzzle.global_transform.origin, pull_strength)
	else:
		pass


func shoot_clouds() -> void:
	var cloud: Cloud = spawn_cloud.instance()
	
	owner.add_child(cloud)
	cloud.global_transform.origin = vacuum_muzzle.global_transform.origin
	cloud.shoot(-player_mesh.global_transform.basis.z, shoot_speed)


func play_animation(anim_name: String) -> void:
	
	match anim_name:
		"Idle":
			character_anim_player.play("Idle")
			character_anim_player.set_speed_scale(1.5)
		
		"Run":
			character_anim_player.play("Walk")
			character_anim_player.set_speed_scale(3)
			
		"Jump":
			character_anim_player.play("Jump")
			character_anim_player.set_speed_scale(2)
		
		"Fall":
			character_anim_player.play("Falling")
			character_anim_player.set_speed_scale(1)
			
		"Flying":
			character_anim_player.play("Goosegrab")
			character_anim_player.set_speed_scale(2)
	
	
func goose_play_animation(anim_name: String):
	match anim_name:
		
		"Glide":
			goose_anim_player.play("Flying_Glide")
			goose_anim_player.set_speed_scale(2)
			
		"Fly":
			goose_anim_player.play("Flying")
			goose_anim_player.set_speed_scale(4)
			
		"Hover":
			goose_anim_player.play("Flying_Hang")
			goose_anim_player.set_speed_scale(4)


func vacuum_play_animation(anim_name: String):
	match anim_name:
		
		"OFF":
			vacuum_anim_player.play("vacuum_dissapear")
			vacuum_anim_player.set_speed_scale(5)
			
		"ON":
			vacuum_anim_player.play("vacuum_emerge")
			vacuum_anim_player.set_speed_scale(5)
			
		"Suck":
			vacuum_anim_player.play("vacuum_suck")
			vacuum_anim_player.set_speed_scale(2)


# Vacuum animation player
func _on_AnimationPlayer_animation_finished(anim_name):
	
	match anim_name:
		"vacuum_emerge":
			vacuum_play_animation("Suck")


func _on_Muzzle_body_entered(body):
	if isSucking:
		# TODO: store clouds somewhere
		body.call_deferred("free")
