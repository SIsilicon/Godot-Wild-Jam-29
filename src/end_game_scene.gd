extends Spatial

onready var tween: Tween = $Tween
onready var village_mesh : MeshInstance = $Environment/Village

var can_quit := false


func _ready() -> void:
	setup_village_texture()
	$Ending.modulate.a = 0.0


func _on_AnimationPlayer_animation_finished(anim_name: String) -> void:
	tween.interpolate_property($Ending, "modulate:a", 0.0, 1.0, 0.5)
	tween.interpolate_callback(self, 0.5, "set", "can_quit", true)
	tween.start()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") and can_quit:
		get_tree().change_scene("res://scenes/ui/MainMenu.tscn")


func setup_village_texture() -> void:
	var material0 : SpatialMaterial = SpatialMaterial.new()
	var material1 : SpatialMaterial = SpatialMaterial.new()
	var material2 : SpatialMaterial = SpatialMaterial.new()
	
	material0.albedo_texture = load("res://models/village/base_diffuse.png")
	material1.albedo_texture = load("res://models/village/roof_diffuse.png")
	material2.albedo_texture = load("res://models/village/border_diffuse.png")
	
	village_mesh.set_surface_material(0, material0)
	village_mesh.set_surface_material(1, material1)
	village_mesh.set_surface_material(2, material2)
