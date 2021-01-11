extends StaticBody

signal navigation_started
signal navigation_finished

# TODO: Implement refuelling
# TODO: Use a proper ship model

const MAX_FUEL = 100.0
const MAP_SIZE = 6000.0

export var acceleration := 10.0
export var stop_distance := 20.0
export var max_speed := 20.0
export var consumption_rate := 5.0
export var fuel := 0.0

var sailing := false
var speed := 0.0

var _target: Vector3
var _player: KinematicBody
var _clouds := []

onready var nav_map: Control = $NavMap
onready var tween: Tween = $Tween


func _ready() -> void:
	nav_map.hide()


func _input(event: InputEvent) -> void:
	if not tween.is_active():
		if event.is_action_pressed("open_navigation") and _player and not nav_map.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			_player.set_process_input(false)
			_player.set_physics_process(false)
			open_navigation()
		if event.is_action_pressed("ui_cancel") and nav_map.visible:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			_player.set_process_input(true)
			_player.set_physics_process(true)
			close_navigation()


func _physics_process(delta: float) -> void:
	$FuelGauge.value = fuel
	
	for cloud in _clouds:
		if not cloud:
			continue
		var to_ship: Vector3 = cloud.translation.direction_to(translation)
		cloud.velocity += to_ship * delta * 40.0
	
	if sailing:
		var to_target := translation.direction_to(_target)
		var facing := transform.basis.z
		var target_angle = atan2(to_target.x, to_target.z)
		rotation.y = wrapf(lerp_angle(rotation.y, target_angle, delta * speed * 0.05), -PI, PI)
		
		var moving := fuel > 0.0 and translation.distance_to(_target) > stop_distance
		speed = move_toward(speed, max_speed if moving else 0.0, delta * acceleration)
		fuel = max(fuel - consumption_rate * delta * float(moving), 0.0)
		translation += facing * speed * delta
		
		if speed == 0.0:
			sailing = false
			emit_signal("navigation_finished")
		
		if nav_map.visible:
			_update_map()


func open_navigation() -> void:
	tween.interpolate_callback(nav_map, 0.0, "show")
	tween.interpolate_property(nav_map, "rect_position:y", Global.base_window_size.y, 0.0, 0.5)
	tween.interpolate_callback(nav_map, 0.5, "set", "mouse_filter", "stop")
	tween.start()
	_update_map()


func close_navigation() -> void:
	tween.interpolate_callback(nav_map, 0.0, "set", "mouse_filter", "ignore")
	tween.interpolate_property(nav_map, "rect_position:y", 0.0, Global.base_window_size.y, 0.5)
	tween.interpolate_callback(nav_map, 0.5, "hide")
	tween.start()


func go_sailing(at: Vector3) -> void:
	_target = at
	sailing = true
	emit_signal("navigation_started")


func _update_map() -> void:
	var ship_marker := $NavMap/Panel/Ship
	ship_marker.rect_rotation = -rotation_degrees.y
	ship_marker.rect_position.x = range_lerp(-translation.x, -MAP_SIZE / 2,
			MAP_SIZE / 2, 0, $NavMap/Panel.rect_size.x)
	ship_marker.rect_position.y = range_lerp(-translation.z, -MAP_SIZE / 2,
			MAP_SIZE / 2, 0, $NavMap/Panel.rect_size.y)
	ship_marker.rect_position -= ship_marker.rect_pivot_offset


func _on_FOI_body_entered(body: Node) -> void:
	if body is Cloud:
		var to_ship: Vector3 = body.translation.direction_to(translation)
		var offset := to_ship.cross(Vector3.UP).rotated(to_ship, rand_range(0, 2*PI))
		body.velocity = offset * 10.0
		body.velocity += to_ship * 5.0
		_clouds.append(body)
	elif body is Player:
		tween.interpolate_property($FuelGauge, "rect_position:y", -30, 8, 0.3)
		tween.start()


func _on_FOI_body_exited(body: Node) -> void:
	if body is Player:
		tween.interpolate_property($FuelGauge, "rect_position:y", 8, -30, 0.3)
		tween.start()


func _on_Steering_body_entered(body: Node) -> void:
	if body is Cloud:
		fuel = min(fuel+0.5, MAX_FUEL)
		body.queue_free()
		if _clouds.has(body):
			_clouds.erase(body)
	elif body is Player:
		_player = body


func _on_Steering_body_exited(body: Node) -> void:
	if body is Player:
		_player = null


func _on_Region_pressed(region: int) -> void:
	get_parent().transition_camera($Camera, 1.0)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_player.set_process_input(true)
	_player.set_physics_process(true)
	close_navigation()

