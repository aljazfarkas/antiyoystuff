extends TileMap

onready var player = get_parent()
onready var pixels_lifted = get_node("/root/World/HexTiles").get_pixels_lifted()
onready var tile_size = get_node("/root/World/HexTiles").cell_size

var used_cells = self.get_used_cells()
const TILES = {'player_area':17,'player_area_lifted':18}

var outlined_tiles = [8,9,10,11,12,13,14,15,16]

"""
Picks a random color for the player tiles.
"""
func _ready():
	randomize()
	var color = Color(rand_range(0,1), rand_range(0,1), rand_range(0,1), 0.6)	
	modulate = color
	_mark_castle_area()

"""
Marks the area around the castle.
"""
func _mark_castle_area():
	#castle tile
	set_cellv(world_to_map(player.get_node("Buildings/Castle").global_position), TILES.player_area)
	#neighbour tiles
	set_cellv(world_to_map(player.get_node("Buildings/Castle").global_position) + Vector2(1,0), TILES.player_area)
	set_cellv(world_to_map(player.get_node("Buildings/Castle").global_position)+ Vector2(-1,0), TILES.player_area)
	set_cellv(world_to_map(player.get_node("Buildings/Castle").global_position)+ Vector2(0,1), TILES.player_area)
	set_cellv(world_to_map(player.get_node("Buildings/Castle").global_position)+ Vector2(0,-1), TILES.player_area)
	set_cellv(world_to_map(player.get_node("Buildings/Castle").global_position)+ Vector2(-1,-1), TILES.player_area)
	set_cellv(world_to_map(player.get_node("Buildings/Castle").global_position)+ Vector2(-1,1), TILES.player_area)

"""
Add the tile to the territory - Therefore also unlifting it.
"""
func add_tile(pos):
	set_cellv(pos,TILES.player_area)

"""
Lifts the tile on the position.
"""
func lift_tile(pos):
	set_cellv(pos,TILES.player_area_lifted)
