extends Spatial


onready var Artifact_Spot1:Spatial = $Piece1_Spot
onready var Artifact_Spot2:Spatial = $Piece2_Spot
onready var Artifact_Spot3:Spatial = $Piece3_Spot

onready var mesh : MeshInstance = $Altar_Mesh/object_altar

onready var artifact = preload("res://scenes/entities/Artifact.tscn")


# Called when the node enters the scene tree for the first time.
func _ready():
	setup()
	update_altar()



func setup() -> void:
	var material : SpatialMaterial = SpatialMaterial.new()
	material.albedo_texture = load("res://models/artifact/altar_diffuse.png")
	
	mesh.set_surface_material(0, material)



func look_for_artifact_piece(part: int, spot: Spatial):
	var parts_list = GameState.parts_collected
	print(parts_list)
	
	if part in parts_list:
		
		GameState.parts_collected.erase(part)
		GameState.piece_to_altar(part)
		update_altar()
		
		
	else:
		print("You don't have this part yet")



func update_altar():
	var parts_on_altar = GameState.parts_on_altar
	var spot: Spatial
	
	if parts_on_altar.size() > 0:
		
		for part in parts_on_altar:
			var artifact_spawned = artifact.instance()
			
			artifact_spawned.get_node("CollisionShape").set_disabled(true)
			artifact_spawned.type = part
			
			match part:
				0:
					spot = Artifact_Spot1
				
				1:
					spot = Artifact_Spot2
					
				2: 
					spot = Artifact_Spot3
				
			
			
			spot.add_child(artifact_spawned)
			

func _on_ArtifactPiece1_body_entered(body):
	if body is Player:
		look_for_artifact_piece(0, Artifact_Spot1)
		$Timer.start(1)
	


func _on_ArtifactPiece2_body_entered(body):
	if body is Player:
		look_for_artifact_piece(1, Artifact_Spot2)
		$Timer.start(1)


func _on_ArtifactPiece3_body_entered(body):
	if body is Player:
		look_for_artifact_piece(2, Artifact_Spot3)
		$Timer.start(1)



func _on_Timer_timeout():
	GameState.check_end_game()
