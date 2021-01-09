extends StaticBody

# TODO: Implement refuelling
# TODO: Implement navigation map
# TODO: Use a proper ship model

const MAX_FUEL = 100.0

export var acceleration := 10.0
export var max_speed := 20.0
export var consumption_rate := 5.0
export var fuel := 100.0

var sailing := false
var speed := 0.0

var _target: Vector3

onready var nav_map: Control = $NavMap
onready var tween: Tween = $Tween


func _input(event: InputEvent) -> void:
	if not tween.is_active():
		if event is InputEventKey and event.pressed:
			if event.scancode == KEY_E and not nav_map.visible:
				open_navigation()
			if event.scancode == KEY_G:
				go_sailing($"../Position3D".translation)
		if event.is_action_pressed("ui_cancel") and nav_map.visible:
			close_navigation()


func _physics_process(delta: float) -> void:
	if sailing:
		var to_target := translation.direction_to(_target)
		var facing := transform.basis.z
		var target_angle = atan2(to_target.x, to_target.z)
		rotation.y = wrapf(lerp_angle(rotation.y, target_angle, delta * speed * 0.05), -PI, PI)
		
		var moving := fuel > 0.0 and translation.distance_to(_target) > 20.0
		speed = move_toward(speed, max_speed if moving else 0.0, delta * acceleration)
		fuel = max(fuel - consumption_rate * delta * float(moving), 0.0)
		translation += facing * speed * delta
		
		if speed == 0.0:
			sailing = false


func open_navigation() -> void:
	tween.interpolate_callback(nav_map, 0.0, "show")
	tween.interpolate_property(nav_map, "rect_position:y", Global.base_window_size.y, 0.0, 0.5)
	tween.interpolate_callback(nav_map, 0.5, "set", "mouse_filter", "stop")
	tween.start()


func close_navigation() -> void:
	tween.interpolate_callback(nav_map, 0.0, "set", "mouse_filter", "ignore")
	tween.interpolate_property(nav_map, "rect_position:y", 0.0, Global.base_window_size.y, 0.5)
	tween.interpolate_callback(nav_map, 0.5, "hide")
	tween.start()


func go_sailing(at: Vector3) -> void:
	_target = at
	sailing = true
