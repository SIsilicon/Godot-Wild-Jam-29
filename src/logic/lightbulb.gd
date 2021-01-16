class_name LightBulb
extends MeshInstance

onready var red_light = load("res://textures/puzzlestuff/lightbulb_texture_red.jpg")
onready var green_light = load("res://textures/puzzlestuff/lightbulb_texture_green.jpg")

func _ready():
	pass


func turn_green():
	var material : SpatialMaterial = SpatialMaterial.new()
	material.albedo_texture = green_light
	set_surface_material(0, material)
	

func turn_red():
	var material : SpatialMaterial = SpatialMaterial.new()
	material.albedo_texture = red_light
	set_surface_material(0, material)
