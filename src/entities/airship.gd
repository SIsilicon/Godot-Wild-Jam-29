class_name Airship
extends StaticBody

# TODO: Refuel at a certain part of the ship.
# TODO: Use a proper ship model.

const MAX_FUEL = 100.0
const MAP_SIZE = 6000.0

export var in_map := false

export var acceleration := 10.0
export var max_speed := 20.0
export var consumption_rate := 5.0
export var fuel := 0.0

var speed := 0.0
var pull_sailing_direction := Vector3.ZERO # This influences the direction the ship travels.

var _player: KinematicBody
var _clouds := []

onready var tween: Tween = $Tween


func _input(event: InputEvent) -> void:
	if not tween.is_active():
		if event.is_action_pressed("open_navigation") and _player:
			if not in_map:
				get_node("../../..").transition_to_map()
			else:
				get_node("../../..").transition_to_world()


func _physics_process(delta: float) -> void:
	if in_map:
		$FuelGauge3D/Viewport/ProgressBar.value = fuel
		$FuelGauge3D/Viewport/Label.visible = fuel <= 0.0
		$FuelGauge3D/Viewport.render_target_update_mode = Viewport.UPDATE_ALWAYS
		$FuelGauge3D.visible = true
		$FuelGauge.visible = false
	else:
		$FuelGauge.value = fuel
		$FuelGauge.visible = true
		$FuelGauge3D.visible = false
		$FuelGauge3D/Viewport.render_target_update_mode = Viewport.UPDATE_DISABLED
	
	for cloud in _clouds:
		if not cloud:
			continue
		var to_ship: Vector3 = cloud.translation.direction_to(translation)
		cloud.velocity += to_ship * delta * 40.0
	
	var direction := Vector3.ZERO
	if fuel and in_map:
		if Input.is_action_pressed("move_forward"):
			direction.z -= 1.0
		if Input.is_action_pressed("move_backward"):
			direction.z += 1.0
		if Input.is_action_pressed("move_left"):
			direction.x -= 1.0
		if Input.is_action_pressed("move_right"):
			direction.x += 1.0
	if direction.length() > 0.0:
		direction += pull_sailing_direction
		direction = direction.normalized()
		var target_angle = atan2(direction.x, direction.z)
		rotation.y = lerp_angle(rotation.y, target_angle, delta * min(speed * 0.05, 2.0))
	
	var moving := direction.length() > 0.0
	speed = move_toward(speed, max_speed if moving else 0.0, delta * acceleration)
	fuel = max(fuel - consumption_rate * delta * float(moving), 0.0)
	translation += global_transform.basis.z.normalized() * speed * delta
	if in_map and _player:
		_player.transform = $PlayerWheelPos.transform
	
#	if sailing:
#		var to_target := translation.direction_to(_target)
#		var facing := transform.basis.z
#		var target_angle = atan2(to_target.x, to_target.z)
#		rotation.y = wrapf(lerp_angle(rotation.y, target_angle, delta * speed * 0.05), -PI, PI)
#
#		var moving := fuel > 0.0 and translation.distance_to(_target) > stop_distance
#		speed = move_toward(speed, max_speed if moving else 0.0, delta * acceleration)
#		fuel = max(fuel - consumption_rate * delta * float(moving), 0.0)
#		translation += facing * speed * delta
#
#		if speed == 0.0:
#			sailing = false
#			emit_signal("navigation_finished")
#
#		if nav_map.visible:
#			_update_map()


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
#		if in_map:
#			_player.set_process_input(false)
#			_player.set_physics_process(false)
#			_player.set_process(false)
		if not in_map:
			var navigate_icon: Sprite3D = _player.get_node("StartNavigate")
			tween.interpolate_property(navigate_icon, "scale", Vector3.ZERO, Vector3.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
			tween.interpolate_callback(navigate_icon, 0.0, "show")
			tween.start()


func _on_Steering_body_exited(body: Node) -> void:
	if body is Player:
		if not in_map:
			var navigate_icon: Sprite3D = _player.get_node("StartNavigate")
			tween.interpolate_property(navigate_icon, "scale", Vector3.ONE, Vector3.ZERO, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
			tween.interpolate_callback(navigate_icon, 0.3, "hide")
			tween.start()
		_player = null
