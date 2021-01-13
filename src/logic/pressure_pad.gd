extends InputDevice



onready var pad_mesh : MeshInstance = $MeshInstance

var pushers : Array = []


# TODO: Add player interactibility.


func update_pushers() -> void:
	if len(pushers) > 0:
		pad_mesh.translation.y = -pad_mesh.mesh.size.y / 2.0
		set_state(States.ENABLED)
	else:
		pad_mesh.translation.y = 0
		set_state(States.DISABLED)



func _on_PressureArea_body_entered(body : PhysicsBody) -> void:
	if body.is_in_group("pushes_pressure_pad"):
		pushers.append(body)
		update_pushers()



func _on_PressureArea_body_exited(body : PhysicsBody) -> void:
	if body.is_in_group("pushes_pressure_pad"):
		pushers.erase(body)
		update_pushers()
