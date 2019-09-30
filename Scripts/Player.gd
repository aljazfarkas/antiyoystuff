extends Node2D

signal turn_over

onready var castle = get_node("Buildings/Castle")
onready var tile_size = get_node("/root/World/HexTiles").cell_size
onready var hextiles = get_node("/root/World/HexTiles")
onready var buildings = get_tree().get_nodes_in_group("buildings")
"""
Spawns a castle. Every player gets one castle.
"""
func _ready():
	pass
func play_turn():
	yield(self,"turn_over")