extends KinematicBody2D
class_name Units

"""
Speed is how fast selected unit travels between tiles.
Reach is between how many tiles the selected unit can travel.
Moves is how many times the selected unit can travel.
"""
export (int) var speed = 300
export (int) var reach = 2
export (int) var available_moves = 1000

onready var tile_size = get_node("/root/World/HexTiles").cell_size
#lifted = the amount of pixels the units or buildings should be lifted for
onready var pixels_lifted = get_node("/root/World/HexTiles").get_pixels_lifted()
onready var hextiles = get_node("/root/World/HexTiles")
onready var buildings = get_tree().get_nodes_in_group("buildings")
onready var player_tiles = get_node("/root/World/TurnQueue/Player/PlayerTiles")

#return if the selected unit is lifted by 15 pixels
var lifted = false setget set_lifted,get_lifted
var selected = false setget set_selected, get_selected

signal was_selected
signal was_deselected
signal turn_over
signal target_arrived

"""
A function to set and emit signals about var selected
We change collision shape position to adapt to lifting tiles.
"""
func set_selected(value):
	if selected != value:
		selected = value
		if selected:
			set_lifted(true)
			emit_signal("was_selected", self)
			#highlight the areas the selected units can move to
			hextiles.highlight_reach(reach,self)
		else:
			set_lifted(false)
			emit_signal("was_deselected", self)
			#dehighlight the areas the selected units can move to
			hextiles.dehighlight_reach(reach,self)

"""
A function that returns if the unit is selected.
"""
func get_selected() -> bool:
	return selected

"""
set_lifted(value) lifts the selected unit up or down by 15 pixels (tiles are lifted for 15 pixels).
Also lifts a building if any building is inside the highlighted area.
"""
func set_lifted(value):
	if value:
		$CollisionShape2D.position.y -= pixels_lifted
		$Sprite.position.y -= pixels_lifted

	else:
		$CollisionShape2D.position.y += pixels_lifted
		$Sprite.position.y += pixels_lifted
	lifted = value

func get_lifted() -> Vector2:
	return lifted