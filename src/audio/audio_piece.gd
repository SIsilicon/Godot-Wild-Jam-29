extends AudioStreamPlayer



func _on_AudioPiece_finished():
	queue_free()
