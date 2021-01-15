extends Node

var parts_collected: Array = []
var parts_on_altar : Array = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func add_artifact_piece(artifact_piece: ArtifactPiece):
	if artifact_piece.type in parts_collected:
		print("You already found this piece. It shouldn't be possible.")
		
	else:
		parts_collected.append(artifact_piece.type)
		
		match artifact_piece.type:
			0:
				print("First piece found")
				
			1:
				print("Second piece found")
				
			2:
				print("Thrid piece found")
	
	
	artifact_piece.call_deferred("free")
	

func piece_to_altar(part_number: int):
	if part_number in parts_on_altar:
		
		print("You already put this piece on the altar. It shouldn't be possible.")
		
	else:
		parts_on_altar.append(part_number)
	
	check_end_game()

func check_end_game():
	
	if parts_on_altar.size() == 3:
		
		get_tree().change_scene_to(load("res://scenes/EndGameScene.tscn"))
		
	else:
		pass
