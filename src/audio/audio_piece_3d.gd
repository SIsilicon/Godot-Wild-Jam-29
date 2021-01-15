extends AudioStreamPlayer3D



var tag : String

signal ended(sfx)



# Public methods

func end() -> void:
	stop()
	emit_signal("ended", self)
	queue_free()



# Private methods

func _on_AudioPiece3D_finished() -> void:
	end()
