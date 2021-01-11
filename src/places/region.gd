class_name Region
extends Area


func _ready() -> void:
	connect("area_entered", self, "_on_area_entered")
	connect("area_exited", self, "_on_area_exited")


func _on_area_entered(area: Area) -> void:
	$"LOD-0".show()
	$"LOD-1".hide()


func _on_area_exited(area: Area) -> void:
	$"LOD-1".show()
	$"LOD-0".hide()
