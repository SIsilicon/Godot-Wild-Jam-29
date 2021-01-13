extends OutputDevice

# TODO: Make look pretty



onready var collision : CollisionShape = $Collision/CollisionShape
onready var animation_player : AnimationPlayer = $AnimationPlayer



# Methods that should/could be called inside and outside of script


func open() -> void:
	collision.disabled = true
	animation_player.play("open")



func close() -> void:
	collision.disabled = false
	animation_player.play("close")



# Methods that shouldn't be called outside of script

func _on_enabled() -> void:
	open()



func _on_disabled() -> void:
	close()
