extends Units

var target = Vector2()
var velocity = Vector2()
var moves = 0
#if they player can move to that tile(if territory is connected)
var can_move = true

func _ready():
	#start the game in the middle of the tile
	target = self.position.snapped(tile_size/2)

func _physics_process(delta):
	velocity = (target - self.position).normalized() * speed
	#check the length so the body doesn't go too far and jitter
	if (target - self.position).length() > 5:
		velocity = move_and_slide(velocity)
	if moves < available_moves:
		emit_signal("turn_over")
	#adds the target tile to the territory
	if hextiles.get_hex_position(position) == hextiles.get_hex_position(target) and player_tiles.get_cellv(player_tiles.world_to_map(target)) == -1 and can_move == true:
		player_tiles.add_tile(player_tiles.world_to_map(target))

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			#only move if the unit is selected AND the click isn't on the same tile as the selected unit
			if selected and (hextiles.get_hex_position(get_global_mouse_position()) != hextiles.get_hex_position(self.position)):
				#before moving set selected to false so you dehighlight all of the highlighted areas
				var hex_position = hextiles.get_hex_position(get_global_mouse_position())
				#highlighted tiles are x_flipped in hextiles.gd
				#target only updates if there is territory around it
				if hextiles.is_cell_x_flipped(hex_position.x,hex_position.y) and player_tiles.check_neighbours(hextiles.map_to_world(hex_position) + tile_size/2):
					#center the selected unit in the tile and dehighlight area
					target = hextiles.map_to_world(hex_position) + tile_size/2
					#position the unit in the middle of the tile(just to be sure)
					target = target.snapped(tile_size/2)
					moves += 1
				set_selected(false)

func _on_Farmer_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton :
		if event.is_pressed():
			#doesn't move if the available_moves are 0 and if the selected unit is still moving
			if event.button_index == BUTTON_LEFT and moves < available_moves and hextiles.get_hex_position(position) == hextiles.get_hex_position(target):
				set_selected(not selected)
				


