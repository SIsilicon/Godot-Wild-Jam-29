extends Spatial

# HACK: All of this



enum Events { START, QUIT }

export var scene : PackedScene
export var alt_scene : PackedScene

onready var fade_animation : AnimationPlayer = $UI/Fade/AnimationPlayer
onready var player_animation : AnimationPlayer = $Misc/char_mc/AnimationPlayer
onready var airship_mesh : MeshInstance = $Misc/object_airship
onready var input_cool_timer : Timer = $InputCoolTimer



func _ready() -> void:
	setup()



func setup() -> void:
	var material : SpatialMaterial = SpatialMaterial.new()
	material.albedo_texture = load("res://textures/airship/airship_base_color.png")
	airship_mesh.set_surface_material(0, material)



func _process(delta : float) -> void:
	player_animation.current_animation = "Idle"



func _input(event : InputEvent) -> void:
	if !input_cool_timer.time_left:
		if event is InputEventKey:
			if event.get_scancode() == KEY_ENTER:
				event(Events.START)
			
			if event.get_scancode() == KEY_ESCAPE:
				event(Events.QUIT)



func event(event : int) -> void:
	fade_animation.play("fade_in")
	yield(fade_animation, "animation_finished")
	
	match event:
		Events.START:
			if Global.settings.play_story: get_tree().change_scene_to(scene)
			else: get_tree().change_scene_to(alt_scene)
		
		Events.QUIT:
			get_tree().quit()
