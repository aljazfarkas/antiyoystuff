extends StaticBody2D
class_name Buildings

onready var buildings = get_tree().get_nodes_in_group("buildings")
onready var pixels_lifted = get_node("/root/World/HexTiles").get_pixels_lifted()
onready var tile_size = get_node("/root/World/HexTiles").cell_size
onready var hextiles = get_node("/root/World/HexTiles")

#return if any building is lifted by 15 pixels
var lifted = false setget set_lifted,get_lifted

func _ready():
	pass

"""s
set_lifted(value) lifts a building if any building is inside the highlighted area of a unit
"""
func set_lifted(value):
	if value:
		for building in buildings:
			building.get_node("CollisionShape2D").position.y -= pixels_lifted
			building.get_node("Sprite").position.y -= pixels_lifted
			
	else:
		for building in buildings:
			building.get_node("CollisionShape2D").position.y += pixels_lifted
			building.get_node("Sprite").position.y += pixels_lifted
	lifted = value

func get_lifted() -> bool:
	return lifted