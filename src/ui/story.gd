extends Control

onready var text_label := $Text
onready var anim_player := $AnimationPlayer
onready var hint := $hint

var text_blurbs := [
	"- Story -\nJohn VaCuum Kleiner, a cleaner, inventor and pioneer, specialises in anything vacuum related!\n1/5",
	"- Story -\nHim and his unforgettable companion, Margaret the Goose, embark on a journey from town to town to spread the knowledge of vacuum cleaners.\n2/5",
	"- Story -\nHowever, on the arrival of their next destination, the pair come across a storm engulfing the entire town...\n3/5",
	"- Story -\nMargaret, with her unmatchable intellect, suggests that the two will have to find 3 artifacts in order to calm the storm.\n4/5",
	"- Story -\nJohn, knowing not to try matching Margaret's intellect, agrees, and the two set forth on a miraculous adventure!\n5/5",
	"- Tip -\nThe pause menu (Esc.) has a help menu, where you can go to better understand the game if need be."
]

signal continue_pressed



func _ready() -> void:
	hint.visible = false
	
	for text in text_blurbs:
		text_label.text = text
		anim_player.play("in")
		yield(anim_player, "animation_finished")
		hint.visible = true
		yield(self, "continue_pressed")
		hint.visible = false
		anim_player.play("out")
		yield(anim_player, "animation_finished")
	
	get_tree().change_scene("res://scenes/places/World.tscn")



func _input(event):
	if event.is_action_pressed("interact"):
		emit_signal("continue_pressed")
