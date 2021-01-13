extends AudioStreamPlayer3D



func _on_AudioPiece3D_finished():
	queue_free()
