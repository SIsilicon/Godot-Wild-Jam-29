extends Spatial

# TODO: Enter another region

const MAP_MIN_LIMIT = 1500.0
const MAP_MAX_LIMIT = 4500.0
const MAP_LIMIT_MARGIN = 500.0

var in_map := false

onready var tween: Tween = $Tween
onready var player: Player = $Level/Viewport/Player
onready var airship: Airship = $Level/Viewport/Airship
onready var current_region := $Level/Viewport/Region1

func _ready() -> void:
	$Level.show()
	$Map.show()
	$Map.modulate.a = 0.0
	set_paused($Map/Viewport, true)


func _process(delta: float) -> void:
	if in_map:
		airship.pull_sailing_direction = Vector3.ZERO
		var ship_trans: Vector3 = airship.translation
		var ship_dist_from_center: float = ship_trans.length()
		if ship_dist_from_center < MAP_MIN_LIMIT:
			airship.pull_sailing_direction += ship_trans.normalized() * min((MAP_MIN_LIMIT - ship_dist_from_center) / MAP_LIMIT_MARGIN, 1.0) * 5.0
		elif ship_dist_from_center > MAP_MAX_LIMIT:
			airship.pull_sailing_direction -= ship_trans.normalized() * min((ship_dist_from_center - MAP_MAX_LIMIT) / MAP_LIMIT_MARGIN, 1.0) * 5.0
	elif $Level/Viewport.get_camera():
		var background_cam := $Level/Viewport/Background/Viewport/Camera
		background_cam.transform.basis = $Level/Viewport.get_camera().global_transform.basis
		background_cam.translation = airship.translation


func transition_to_world() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$Map/Viewport.remove_child(airship)
	$Level/Viewport.add_child(airship)
	airship.speed = 0.0
	airship.rotation_degrees = Vector3(0, 90, 0)
	airship.scale = Vector3.ONE
	airship.in_map = false
	
	airship.remove_child(player)
	$Level/Viewport.add_child(player)
	player.velocity = Vector3.ZERO
	player.global_transform = airship.get_node("PlayerWheelPos").global_transform
	player.enter_state(Player.States.IDLE)
	
	var map_cam_remote := airship.get_node("CamRemote")
	airship.remove_child(map_cam_remote)
	$Map/Viewport.add_child(map_cam_remote)
	
	player.get_node("GimbalX/GimbalY/CameraPosition/Camera").make_current()
	
	set_paused($Level/Viewport, false)
	set_paused($Map/Viewport, true)
	$Level/Viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
	
	set_paused(airship, true)
	tween.interpolate_property($Level, "modulate:a", 0.0, 1.0, 0.5)
	tween.interpolate_property($Map, "modulate:a", 1.0, 0.0, 0.5)
	tween.interpolate_callback(self, 0.5, "set_paused", airship, false)
	tween.interpolate_callback(self, 0.5, "set", "in_map", false)
	tween.start()


func transition_to_map() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if current_region:
		current_region.queue_free()
	
	$Level/Viewport.remove_child(airship)
	$Map/Viewport.add_child(airship)
	airship.rotation_degrees = Vector3(0, 90, 0)
	airship.scale = Vector3(5, 5, 5)
	airship.in_map = true
	
	$Level/Viewport.remove_child(player)
	airship.add_child(player)
	player.enter_state(Player.States.STEERING)
	
	var map_cam_remote := $Map/Viewport/CamRemote
	$Map/Viewport.remove_child(map_cam_remote)
	airship.add_child(map_cam_remote)
	
	$Map/Viewport/CamRoot/Camera.make_current()
	
	set_paused($Map/Viewport, false)
	set_paused($Level/Viewport, true)
	$Map/Viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
	
	set_paused(airship, true)
	tween.interpolate_property($Level, "modulate:a", 1.0, 0.0, 0.5)
	tween.interpolate_property($Map, "modulate:a", 0.0, 1.0, 0.5)
	tween.interpolate_callback(self, 0.5, "set_paused", airship, false)
	tween.interpolate_callback(self, 0.5, "set", "in_map", true)
	tween.start()


func set_paused(node: Node, paused: bool, recursive:=true) -> void:
	if paused and not node.has_meta("_pause_status"):
		var pause_stat := {
			process = node.is_processing(),
			physics_process = node.is_physics_processing(),
			input = node.is_processing_input(),
			unhandled_input = node.is_processing_unhandled_input(),
		}
		if node is RigidBody:
			pause_stat.body_mode = node.mode
		if node is Viewport:
			pause_stat.view_update = node.render_target_update_mode
			pause_stat.view_gui = node.gui_disable_input
		node.set_meta("_pause_status", pause_stat)
		
		node.set_process(false)
		node.set_physics_process(false)
		node.set_process_input(false)
		node.set_process_unhandled_input(false)
		if node is RigidBody:
			node.mode = RigidBody.MODE_STATIC
		if node is Viewport:
			node.render_target_update_mode = Viewport.UPDATE_DISABLED
			node.gui_disable_input = true
	
	elif not paused and node.has_meta("_pause_status"):
		var pause_stat: Dictionary = node.get_meta("_pause_status")
		node.remove_meta("_pause_status")
		
		node.set_process(pause_stat.process)
		node.set_physics_process(pause_stat.physics_process)
		node.set_process_input(pause_stat.input)
		node.set_process_unhandled_input(pause_stat.unhandled_input)
		if node is RigidBody:
			node.mode = pause_stat.body_mode
		if node is Viewport:
			node.render_target_update_mode = pause_stat.view_update
			node.gui_disable_input = pause_stat.view_gui
	
	if recursive:
		for child in node.get_children():
			set_paused(child, paused)
