extends KinematicBody2D

"""
Speed is how fast selected unit travels between tiles.
Reach is between how many tiles the selected unit can travel.
Moves is how many times the selected unit can travel.
"""
export (int) var speed = 300
export (int) var reach = 5
export (int) var available_moves = 1000

onready var tile_size = get_node("/root/World/TileMap").cell_size
onready var tilemap = get_node("/root/World/TileMap")

var target = Vector2()
var velocity = Vector2()
var moves = 0

#return if the selected unit is lifted by 15 pixels
var lifted = false setget set_lifted,get_lifted
var selected = false setget set_selected, get_selected

signal was_selected
signal was_deselected
signal turn_over

func _ready():
	add_to_group("units")
	#start the game in the middle of the tile
	position = position.snapped(tile_size)
	target = position + Vector2(0,-24)

func _physics_process(delta):
	velocity = (target - position).normalized() * speed
	#check the length so the body doesn't go too far and jitter
	if (target - position).length() > 5:
		velocity = move_and_slide(velocity)
	if moves < available_moves:
		emit_signal("turn_over")

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			#only move if the unit is selected and the click isn't on the same tile as the selected unit
			if selected and (tilemap.get_hex_position(get_global_mouse_position()) != tilemap.get_hex_position(self.position)):
				#before moving set selected to false so you dehighlight all of the highlighted areas
				var hex_position = tilemap.get_hex_position(get_global_mouse_position())
				#highlighted tiles are x_flipped in Tilemap.gd
				if tilemap.is_cell_x_flipped(hex_position.x,hex_position.y):
					#center the selected unit in the tile and dehighlight area
					target = tilemap.map_to_world(hex_position) + tile_size/2 + Vector2(0,7)
					moves += 1
				set_selected(false)

func play_turn():
	yield(self,"turn_over")

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
			tilemap.highlight_reach(reach,self)
		else:
			set_lifted(false)
			emit_signal("was_deselected", self)
			#dehighlight the areas the selected units can move to
			tilemap.dehighlight_reach(reach,self)

"""
A function that returns if the unit is selected.
"""
func get_selected():
	return selected

"""
set_lifted(value) lifts the selected unit up or down by 15 pixels (tiles are lifted for 15 pixels)
"""
func set_lifted(value):
	if value:
		$CollisionShape2D.position.y -= 15
		$Sprite.position.y -= 15
	else:
		$CollisionShape2D.position.y += 15
		$Sprite.position.y += 15
	lifted = value

func get_lifted():
	return lifted
"""
When you touch this unit.
"""
func _on_Human_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton :
		if event.is_pressed():
			#doesn't move if the available_moves are 0 and if the selected unit is still moving
			if event.button_index == BUTTON_LEFT and moves < available_moves and tilemap.get_hex_position(position) == tilemap.get_hex_position(target):
				set_selected(not selected)