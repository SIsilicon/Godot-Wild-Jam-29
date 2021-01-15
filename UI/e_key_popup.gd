tool
extends Sprite3D

export var message := "Action" setget set_message

onready var tween: Tween = $Tween


func _ready() -> void:
	if not Engine.editor_hint:
		scale = Vector3.ZERO
	set_message(message)


func set_message(val: String) -> void:
	message = val
	$Viewport/Label.text = message
	$Viewport.render_target_update_mode = Viewport.UPDATE_ONCE


func show_popup() -> void:
	tween.interpolate_property(self, "scale", Vector3.ZERO, Vector3.ONE, 0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.interpolate_deferred_callback(self, 0.0, "set_visible", "true")
	tween.start()


func hide_popup() -> void:
	tween.interpolate_property(self, "scale", Vector3.ONE, Vector3.ZERO, 0.3, Tween.TRANS_CUBIC, Tween.EASE_IN)
	tween.interpolate_deferred_callback(self, 0.3, "set_visible", "false")
	tween.start()
