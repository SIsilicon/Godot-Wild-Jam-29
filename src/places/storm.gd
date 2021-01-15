tool
extends MeshInstance

export var dissolve: float = 0.0 setget set_dissolve

func dissipate() -> void:
	var material: ShaderMaterial = get_surface_material(0).duplicate()
	var sub_material := material.next_pass.duplicate()
	material.next_pass = sub_material
	set_surface_material(0, material)
	$AnimationPlayer.play("dissipate")


func set_dissolve(value: float) -> void:
	dissolve = value
	value = range_lerp(value, 0.0, 1.0, 0.4, 0.6)
	get_surface_material(0).set_shader_param("dissolve", value)
	get_surface_material(0).next_pass.set_shader_param("dissolve", value)
