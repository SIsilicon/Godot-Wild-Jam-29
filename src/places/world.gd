extends Spatial

signal camera_transition_started(new_target)
signal camera_transition_finished(new_target)

var _camera_target: Spatial
var _prev_camera_target: Spatial
var _camera_transition := 1.0

onready var player: KinematicBody = $Player
onready var airship: StaticBody = $Airship
onready var camera: Camera = $Camera
onready var tween: Tween = $Tween

onready var regions := [$Region1]

func _ready() -> void:
	_camera_target = $Player/GimbalX/GimbalY/CameraPosition/Camera


func _process(delta: float) -> void:
	var target_trans: Transform
	if not _prev_camera_target:
		target_trans = _camera_target.global_transform
	else:
		target_trans = _prev_camera_target.global_transform.interpolate_with(
			_camera_target.global_transform, _camera_transition
		)
	$Camera.transform = target_trans


func transition_camera(new_target: Spatial, duration := 0.5) -> void:
	_prev_camera_target = _camera_target
	_camera_target = new_target
	_camera_transition = 0.0
	
	emit_signal("camera_transition_started", new_target)
	tween.interpolate_property(
			self, "_camera_transition", 0.0, 1.0, duration,
			Tween.TRANS_CUBIC, Tween.EASE_IN_OUT
	)
	tween.interpolate_callback(self, duration, "emit_signal", "camera_transition_finished", new_target)
	tween.start()
