tool
extends MeshInstance

func dissipate() -> void:
	if Engine.editor_hint:
		return
	
	var material: ShaderMaterial = material_override.duplicate()
	var sub_material := material.next_pass.duplicate()
	material.next_pass = sub_material
	material_override = material
	$AnimationPlayer.play("dissipate")
