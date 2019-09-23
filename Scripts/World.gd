extends Node2D

var units
var selected_unit
onready var unit_info = $CanvasLayer/Info
onready var unit_icon = $CanvasLayer/Info/Sprite
onready var unit_name = $CanvasLayer/Info/Name
onready var unit_desc = $CanvasLayer/Info/Description


func _ready():
	units = get_tree().get_nodes_in_group("units")
	for unit in units:
		unit.connect("was_selected", self, "_on_selected")
		unit.connect("was_deselected", self, "_on_deselected")

func create_info(body):
	#creating a sprite representing the unit
	unit_icon.texture = body.get_node("Sprite").texture
	#creating a label representing unit's name
	unit_name.text = body.name
	#creating a label representing unit's description
	if "Human" in body.name:
		unit_desc.text = "A farmer likes to farm. Has a lot of farms."
	


func _on_selected(body):
	unit_info.visible = true
	create_info(body)

func _on_deselected(body):
	delete_info()		
func delete_info():
		unit_info.visible = false
