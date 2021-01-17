extends Spatial


export var lightbulb_1_on: bool
export var lightbulb_2_on: bool
export var lightbulb_3_on: bool
export var lightbulb_4_on: bool

onready var light_bulb1: LightBulb = $lightbulb
onready var light_bulb2: LightBulb = $lightbulb2
onready var light_bulb3: LightBulb = $lightbulb3
onready var light_bulb4: LightBulb = $lightbulb4

func _ready():
	
	if lightbulb_1_on:
		light_bulb1.turn_green()
	else:
		light_bulb1.turn_red()
		
		
		
	if lightbulb_2_on:
		light_bulb2.turn_green()
	else:
		light_bulb2.turn_red()
		
		
		
	if lightbulb_3_on:
		light_bulb3.turn_green()
	else:
		light_bulb3.turn_red()
		
		
		
		
	if lightbulb_4_on:
		light_bulb4.turn_green()
	else:
		light_bulb4.turn_red()
