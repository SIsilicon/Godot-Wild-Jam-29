extends Area

func _ready():
	pass


func _on_Antifall_area_body_entered(body):
	if body is Player:
		body.global_transform.origin = global_transform.origin
