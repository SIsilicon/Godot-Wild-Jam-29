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

var _map_region: Region
var _player: KinematicBody

onready var tween: Tween = $Tween


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("open_navigation"):
		if not in_map and _player:
			$CollisionShape.disabled = true
			get_node("../../..").transition_to_map()
		elif in_map:
			$CollisionShape.disabled = false
			$EKeyPopop.hide_popup()
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
	
	var prev_fuel := fuel
	fuel = max(fuel - consumption_rate * delta * float(moving), 0.0)
	if prev_fuel != fuel and fuel == 0.0 and in_map:
		_player.get_node("EKeyPopup").message = "Return to Ship"
		tween.interpolate_callback($EKeyPopop, 1.0, "show_popup")
		tween.start()
	
	translation += global_transform.basis.z.normalized() * speed * delta
	if in_map and _player:
		_player.transform = $PlayerWheelPos.transform

# These next two function are connected by both area and body_entered

func _on_FOI_body_entered(body: Node) -> void:
	if body is Player:
		tween.interpolate_property($FuelGauge, "rect_position:y", -30, 8, 0.3)
		tween.start()
	elif body is Region:
		_map_region = body
		$EKeyPopop.message = "Go to Region"
		$EKeyPopop.show_popup()


func _on_FOI_body_exited(body: Node) -> void:
	if body is Player:
		tween.interpolate_property($FuelGauge, "rect_position:y", 8, -30, 0.3)
		tween.start()
	elif body is Region:
		_map_region = null
		$EKeyPopop.hide_popup()


func _on_Steering_body_entered(body: Node) -> void:
	if body is Player:
		_player = body
#		if in_map:
#			_player.set_process_input(false)
#			_player.set_physics_process(false)
#			_player.set_process(false)
		if not in_map:
			_player.get_node("EKeyPopup").message = "Start Navigating"
			_player.get_node("EKeyPopup").show_popup()


func _on_Steering_body_exited(body: Node) -> void:
	if body is Player:
		if not in_map:
			_player.get_node("EKeyPopup").hide_popup()
			_player = null


func _on_Collector_body_entered(body: Node) -> void:
	if body is Cloud:
		fuel = min(fuel+0.5, MAX_FUEL)
		body.queue_free()
