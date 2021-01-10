extends OutputDevice

# TODO: Make look pretty



onready var animation_player = $AnimationPlayer



# Methods that should/could be called inside and outside of script


func open() -> void:
	animation_player.play("open")



func close() -> void:
	animation_player.play("close")



# Methods that shouldn't be called outside of script

func _on_enabled() -> void:
	open()



func _on_disabled() -> void:
	close()
