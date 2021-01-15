extends AudioStreamPlayer



var tag : String

signal ended(sfx)



# Public methods

func end() -> void:
	stop()
	emit_signal("ended", self)
	queue_free()



# Private methods

func _on_AudioPiece_finished() -> void:
	end()
