extends TileMap

export (int) var WIDTH = 100 setget ,get_width
export (int) var HEIGHT = 100 setget ,get_height

var tile_size = cell_size

var open_simplex_noise

var lifted = Vector2(0,15)

var units = []

const TILES = {
	'dirt': 0,
	'sand': 1,
	'dead': 2,
	'orange': 3,
	'grass': 4,
	'snow': 5,
	'magic': 6,
	'ice': 7,
	'dirt_out' : 8,
	'sand_out' : 9,
	'dead_out' : 10,
	'orange_out' : 11,
	'snow_out' : 13,
	'grass_out' : 14,
	'ice_out' : 15,
	'magic_out' : 16
	}
"""
_ready() creates a new noise and gets all units in units group
"""
func _ready():
	randomize()
	open_simplex_noise = OpenSimplexNoise.new()
	open_simplex_noise.seed = randi()
	
	open_simplex_noise.octaves = 2
	open_simplex_noise.period = 50
	open_simplex_noise.lacunarity = 3
	open_simplex_noise.persistence = 0

	_generate_world()
	
	units = get_tree().get_nodes_in_group("units")

"""
_generate_world() assigns a tile for every cell in the tilemap
"""
func _generate_world():
	for x in WIDTH:
		for y in HEIGHT:
			set_cellv(Vector2(x - WIDTH/2,y - HEIGHT/2),_get_tile_index(open_simplex_noise.get_noise_2d(float(x),float(y))))
#for autotiles:
#	$TileMap.update_bitmask_region()

"""
_get_tile_index(noise_sample) returns an enum depending on the value of the
noise in the specific position
"""
func _get_tile_index(noise_sample):
	if noise_sample < -0.3:
		return TILES.grass
	if noise_sample < 0:
		return TILES.dirt
	if noise_sample < 0.2:
		return TILES.sand
	else:
		return TILES.ice

"""
Get_hex_position(pos) Returns the MAP position of the wanted hexagon given the position.
We add var lifted to account for the tiles that are highlighte, therefore lifted.
"""
func get_hex_position(pos):
	var hex_position = Vector2()
	#14 pixels is the height of the triangle outside the squares of the hexagon	
	var hex_triangle_height = 14
	#sides_vector is the y distance of how far away from the tile square the actual hexagon tile borders are(the triangle under the square)
	var sides_vector = Vector2(0,hex_triangle_height * (1-(abs(tile_size.x/2-abs(fmod(pos.x,tile_size.x))))/(tile_size.x/2)))
	#tile_pos is the map position of the tilemap square we clicked on
	var tile_pos = get_parent().get_node("TileMap").world_to_map(pos)
	#if the mouse_pos and sides_vector is still the same tile, we are still inside the actual hexagon borders
	if (abs(fmod(pos.y,tile_size.y + hex_triangle_height)) > tile_size.y):
		hex_position = get_parent().get_node("TileMap").world_to_map(pos - sides_vector + lifted)
	#we only change the hex_position location if we are outside the square in the hexagon		
	elif((abs(fmod(pos.y,tile_size.y + hex_triangle_height)) < tile_size.y) and (abs(fmod(pos.y,tile_size.y)) > hex_triangle_height)):
		hex_position = tile_pos
	#if we are above the square remove the area above the square and add in the sides_vector(to add the triangle shape)
	else:
		hex_position = get_parent().get_node("TileMap").world_to_map(pos + sides_vector - Vector2(0,hex_triangle_height) + lifted)
	return hex_position
	
"""
	Highlights the tiles the selected units can move to. The tiles are reach distance away from the selected unit. 
"""
func highlight_reach(reach,body):
	var reach_even = reach
	var reach_odd = reach
	var current_tile = get_hex_position(body.position)
	if int(current_tile.y) % 2 == 0:
		for height in range(0,reach + 1):
			if height % 2 == 0:
				for length in range(0,reach_even + 1):
					outline_tile(current_tile + Vector2(0,height) + Vector2(length,0))
					outline_tile(current_tile + Vector2(0,height) + Vector2(- length,0))
					outline_tile(current_tile + Vector2(0,-height) + Vector2(length,0))
					outline_tile(current_tile + Vector2(0,-height) + Vector2(- length,0))
				reach_even -= 1
			else:
				for length in range(0,reach_odd):
					outline_tile(current_tile + Vector2(0,height) + Vector2(-length-1,0))
					outline_tile(current_tile + Vector2(0,height) + Vector2(length,0))
					outline_tile(current_tile + Vector2(0,-height) + Vector2(-length-1,0))
					outline_tile(current_tile + Vector2(0,-height) + Vector2(length,0))
				reach_odd -= 1
	else:
		for height in range(0,reach + 1):
			if height % 2 == 0:
				for length in range(0,reach_even + 1):
					outline_tile(current_tile + Vector2(0,height) + Vector2(length,0))
					outline_tile(current_tile + Vector2(0,height) + Vector2(- length,0))
					outline_tile(current_tile + Vector2(0,-height) + Vector2(length,0))
					outline_tile(current_tile + Vector2(0,-height) + Vector2(- length,0))
				reach_even -= 1
			else:
				for length in range(0,reach_odd):
					outline_tile(current_tile + Vector2(0,height) + Vector2(-length,0))
					outline_tile(current_tile + Vector2(0,height) + Vector2(length + 1,0))
					outline_tile(current_tile + Vector2(0,-height) + Vector2(-length,0))
					outline_tile(current_tile + Vector2(0,-height) + Vector2(length + 1,0))
				reach_odd -= 1
	#dehighlight the tile a unit stands on
	deoutline_tile(current_tile)
	#dehighlights other units in the moveable area
	for unit in units:
		if is_cell_x_flipped(get_hex_position(unit.position).x,get_hex_position(unit.position).y) and unit.get_lifted() == false:
			unit.set_lifted(true)
			deoutline_tile(get_hex_position(unit.position))

"""
Dehighlights the tiles the selected units can move to.
"""
func dehighlight_reach(reach,body):
	var reach_even = reach
	var reach_odd = reach
	var current_tile = get_hex_position(body.position)
	if int(current_tile.y) % 2 == 0:
		for height in range(0,reach + 1):
			if height % 2 == 0:
				for length in range(0,reach_even + 1):
					deoutline_tile(current_tile + Vector2(0,height) + Vector2(length,0))
					deoutline_tile(current_tile + Vector2(0,height) + Vector2(- length,0))
					deoutline_tile(current_tile + Vector2(0,-height) + Vector2(length,0))
					deoutline_tile(current_tile + Vector2(0,-height) + Vector2(- length,0))
				reach_even -= 1
			else:
				for length in range(0,reach_odd):
					deoutline_tile(current_tile + Vector2(0,height) + Vector2(-length-1,0))
					deoutline_tile(current_tile + Vector2(0,height) + Vector2(length,0))
					deoutline_tile(current_tile + Vector2(0,-height) + Vector2(-length-1,0))
					deoutline_tile(current_tile + Vector2(0,-height) + Vector2(length,0))
				reach_odd -= 1
	else:
		for height in range(0,reach + 1):
			if height % 2 == 0:
				for length in range(0,reach_even + 1):
					deoutline_tile(current_tile + Vector2(0,height) + Vector2(length,0))
					deoutline_tile(current_tile + Vector2(0,height) + Vector2(- length,0))
					deoutline_tile(current_tile + Vector2(0,-height) + Vector2(length,0))
					deoutline_tile(current_tile + Vector2(0,-height) + Vector2(- length,0))
				reach_even -= 1
			else:
				for length in range(0,reach_odd):
					deoutline_tile(current_tile + Vector2(0,height) + Vector2(-length,0))
					deoutline_tile(current_tile + Vector2(0,height) + Vector2(length + 1,0))
					deoutline_tile(current_tile + Vector2(0,-height) + Vector2(-length,0))
					deoutline_tile(current_tile + Vector2(0,-height) + Vector2(length + 1,0))
				reach_odd -= 1
	#dehighlights other units in the moveable area
	for unit in units:
		if not is_cell_x_flipped(get_hex_position(unit.position).x,get_hex_position(unit.position).y) and unit.get_lifted() == true:
			unit.set_lifted(false)
"""
outline_tile(pos) replaces a tile with an outlined tile at a given WORLD position.
If a cell is outlined, it is x_flipped
"""
func outline_tile(pos):
	match get_cellv(pos):
		0: set_cellv(pos,TILES.dirt_out,true)
		1: set_cellv(pos,TILES.sand_out,true)
		2: set_cellv(pos,TILES.dead_out,true)
		3: set_cellv(pos,TILES.orange_out,true)
		4: set_cellv(pos,TILES.grass_out,true)
		5: set_cellv(pos,TILES.snow_out,true)
		6: set_cellv(pos,TILES.magic_out,true)
		7: set_cellv(pos,TILES.ice_out,true)
#
func deoutline_tile(pos):
	match get_cellv(pos):
		8: set_cellv(pos,TILES.dirt,false)
		9: set_cellv(pos,TILES.sand,false)
		10: set_cellv(pos,TILES.dead,false)
		11: set_cellv(pos,TILES.orange,false)
		13: set_cellv(pos,TILES.snow,false)
		14: set_cellv(pos,TILES.grass,false)
		15: set_cellv(pos,TILES.ice,false)
		16: set_cellv(pos,TILES.magic,false)

func get_height():
	return HEIGHT

func get_width():
	return WIDTH