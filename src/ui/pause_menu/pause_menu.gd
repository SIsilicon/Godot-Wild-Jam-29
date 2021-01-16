extends Control



enum ButtonTypes { DEFAULT, RETURN, QUIT }

export var panel_color : Color
export var grayed_out_color : Color
export var panel_size : float

var panel_x_offset : float = 0
var panels : Array = []

onready var settings_panel : Control = new_panel([
	new_label("-[Settings]-"),
	new_bool_button("invert_y", "Invert Y-Axis"),
	new_bool_button("fullscreen", "Fullscreen"),
	new_button("Return", null, ButtonTypes.RETURN)
])

onready var credits_panel : Control = new_panel([
	new_label("-[Credits]-\n"),
	new_label("3D Modelling"),
	new_label("\t- Chembini\n"),
	new_label("Composing"),
	new_label("\t- Isabella Lau\n"),
	new_label("Programming"),
	new_label("\t- Jestem Stefan"),
	new_label("\t- SISilicon"),
	new_label("\t- Isaac Astell\n"),
	new_label("Game design"),
	new_label("\t- Everyone!"),
	new_button("Return", null, ButtonTypes.RETURN)
])

onready var controls_panel : Control = new_panel([
	new_label("-[Controls]-\n"),
	new_label("Movement\n- WASD\n"),
	new_label("Jump\n- SPACE\n"),
	new_label("Toggle flight\n- SPACE (airborne)\n"),
	new_label("Shoot clouds\n- LEFT MOUSE BUTTON\n"),
	new_label("Suck in clouds\n- RIGHT MOUSE BUTTON\n"),
	new_label("Interact\n- E\n"),
	new_label("Toggle fullscreen\n- ALT+ENTER\n"),
	new_button("Return", null, ButtonTypes.RETURN)
])

onready var h2p_panel : Control = new_panel([
	new_label("-[How To Play]-\n"),
	new_label("Collect the 3 artifacts\nthen take them to the \naltar to destroy \nthe storm!\n"),
	new_label("Complete puzzles and\nexplore to find the\nartifacts!\n"),
	new_button("Controls", controls_panel),
	new_button("Return", null, ButtonTypes.RETURN)
])

onready var puzzles_panel : Control = new_panel([
	new_label("-[Puzzle Elements]-\n"),
	new_label("_Balloon_______________"),
	new_label("Shoot clouds at the\nballoon to fill it up!\n"),
	new_label("_Pressure_Pad__________"),
	new_label("Put something heavy\non this, such as \nyourself, or a heavy \nstone to activate it!\n"),
	new_label("_Lever_________________"),
	new_label("Switch this up or\ndown to toggle!\nUp = off, Down = on.\n"),
	new_label("_Cyl___________________"),
	new_label("Nothing but a heavy\ncylindrical stone!\n"),
	new_button("Return", null, ButtonTypes.RETURN)
])

onready var help_panel : Control = new_panel([
	new_label("-[Help]-\n"),
	new_float_slider("test", "music_volume", 0.5),
	new_button("Controls", controls_panel),
	new_button("How to play", h2p_panel),
	new_button("Puzzle elements", puzzles_panel),
	new_button("Return", null, ButtonTypes.RETURN)
])

onready var main_panel : Control = new_panel([
	new_label("-[Paused]-\n"),
	new_button("Settings", settings_panel),
	new_button("Help", help_panel),
	new_button("Credits", credits_panel),
	new_button("Quit", null, ButtonTypes.QUIT),
])



# Methods to be used inside/outside of script

func pause() -> void:
	visible = true



func unpause() -> void:
	visible = false



# Methods to be used inside of script only

func _ready() -> void:
	add_panel(main_panel)
#	pause()



func update_panel_selection() -> void:
	for panel in get_tree().get_nodes_in_group("pause_panel"):
		for child in panel.get_children():
			if child.is_in_group("gray_out"):
				child.queue_free()
		
		if panel.rect_position.x != panel_x_offset - panel_size:
			var gray_out : ColorRect = ColorRect.new()
			
			gray_out.anchor_bottom = 1
			gray_out.rect_size.x = panel_size
			gray_out.color = grayed_out_color
			gray_out.add_to_group("gray_out")
			
			panel.add_child(gray_out)



func add_panel(panel : Control) -> void:
	panel.add_to_group("pause_panel")
	
	panel.rect_position.x = panel_x_offset
	panel_x_offset += panel_size
	
	panels.append(panel)
	
	panel.visible = true
	if not panel in get_children(): add_child(panel)
	update_panel_selection()



func pop_panel(count : int = 1) -> void:
	for _i in count:
		panel_x_offset -= panel_size
		panels[-1].visible = false # HACK: Using visiblity change right now because `remove_child` bugs the UI
		panels.pop_back()
	
	update_panel_selection()



func new_panel(gadgets : Array) -> Control:
	var control : Control = Control.new()
	var background : ColorRect = ColorRect.new()
	var vbox : VBoxContainer = VBoxContainer.new()
	
	for gadget in gadgets:
		vbox.add_child(gadget)
	
	background.anchor_right = 1
	background.anchor_bottom = 1
	background.color = panel_color
	
	vbox.anchor_left = 0.05
	vbox.anchor_right = 0.95
	vbox.anchor_top = 0.05
	vbox.anchor_bottom = 0.95
	
	control.anchor_bottom = 1
	control.rect_size.x = panel_size
	
	control.add_child(background)
	control.add_child(vbox)
	
	return control



func new_label(text : String) -> Label:
	var label_packed : PackedScene = load("res://scenes/ui/PauseLabel.tscn")
	var label : Label = label_packed.instance()
	
	label.text = text
	
	return label



func new_button(text : String, opens_panel : Control = null, button_type : int = PauseMenuButton.ButtonTypes.DEFAULT) -> PauseMenuButton:
	var button_packed : PackedScene = load("res://scenes/ui/PauseButton.tscn")
	var button : PauseMenuButton = button_packed.instance()
	
	button.text = text
	button.opens_panel = opens_panel
	button.button_type = button_type
	
	var _e = button.connect("button_pressed", self, "button_pressed")
	
	return button



func new_bool_button(setting : String, text : String, enabled : bool = false) -> HBoxContainer:
	var button_packed : PackedScene = load("res://scenes/ui/BooleanButton.tscn")
	var button : HBoxContainer = button_packed.instance()
	
	button.set_text(text)
	button.set_state(enabled)
	button.set_setting(setting)
	
	button.connect("toggled", self, "bool_button_toggled")
	
	return button



func new_float_slider(setting : String, text : String, value : float = 1.0) -> VBoxContainer:
	var slider_packed : PackedScene = load("res://scenes/ui/PauseFloatSlider.tscn")
	var slider : VBoxContainer = slider_packed.instance()
	
	slider.set_text(text)
	slider.set_value(value)
	slider.set_setting(setting)
	
	slider.connect("value_changed", self, "float_slider_changed")
	
	return slider



func button_pressed(button : PauseMenuButton) -> void:
	match button.button_type:
		ButtonTypes.DEFAULT:
			pass
		
		ButtonTypes.RETURN:
			pop_panel()
		
		ButtonTypes.QUIT:
			get_tree().quit()
	
	if button.opens_panel:
		add_panel(button.opens_panel)



func bool_button_toggled(button : HBoxContainer) -> void:
	set_setting(button.setting, button.is_enabled())



func float_slider_changed(slider : VBoxContainer) -> void:
	print(slider.slider.value)
	set_setting(slider.setting, slider.slider.value)



func set_setting(setting : String, value) -> void:
	Global.set_setting(setting, value)
