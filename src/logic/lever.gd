extends InputDevice


var player: Player


onready var lever : Spatial = $object_lever
onready var lever_anim : AnimationPlayer = $object_lever/AnimationPlayer
onready var area : Area = $Area
onready var light_bulb: LightBulb = $lightbulb

export var starts_as_on: bool = false




# Methods not to be used outside of script

func _ready() -> void:
	
	if starts_as_on and is_logic_NOT_gate:
		turn_on_at_start()
		update()
	
	elif starts_as_on:
		turn_on_at_start()
		update()
		
	else:
		update()
	
		



func _process(delta : float) -> void:
	var player_found := false
	
	for body in area.get_overlapping_bodies():
		if body is Player:
			if body != player:
				player = body
				player.get_node("EKeyPopup").message = "Toggle"
				player.get_node("EKeyPopup").show_popup()
			player_found = true
			break
	
	if not player_found and player:
		player.get_node("EKeyPopup").hide_popup()
		player = null



func _input(event : InputEvent) -> void:
	if event.is_action_pressed("interact"):
		for body in area.get_overlapping_bodies():
			if body is Player:
				toggle()
				update()
				break



func update() -> void:
	if !is_logic_NOT_gate:
		match state:

			States.ENABLED:
				
				lever_anim.play("lever_down")
				light_bulb.turn_green()
			
			States.DISABLED:
				lever_anim.play("lever_up")
				light_bulb.turn_red()
	else:
		match state:

			States.DISABLED:
				
				lever_anim.play("lever_down")
				light_bulb.turn_green()
			
			States.ENABLED:
				lever_anim.play("lever_up")
				light_bulb.turn_red()


func turn_on_at_start():
	toggle()
