extends Spatial

onready var tween: Tween = $Tween

var can_quit := false


func _ready() -> void:
	$Ending.modulate.a = 0.0


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	tween.interpolate_property($Ending, "modulate:a", 0.0, 1.0, 0.5)
	tween.interpolate_callback(self, 0.5, "set", "can_quit", true)
	tween.start()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and can_quit:
		get_tree().quit()
