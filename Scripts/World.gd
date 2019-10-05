extends Node2D

var load_farmer = preload("res://Scenes/Farmer.tscn")

var units
#used in unit picker
var selected_unit

#used in creating info
onready var unit_info = $CanvasLayer/Info
onready var unit_icon = $CanvasLayer/Info/Sprite
onready var unit_name = $CanvasLayer/Info/Name
onready var unit_desc = $CanvasLayer/Info/Description

func _ready():
	#shapes unit picker
	$CanvasLayer/Info/NinePatchRect.rect_size = Vector2(get_viewport_rect().size.x,get_viewport_rect().size.y/4)
	$CanvasLayer/Info/NinePatchRect.margin_top = -get_viewport_rect().size.y/4
	$CanvasLayer/Info/NinePatchRect.margin_bottom = 0
	
#
	units = get_tree().get_nodes_in_group("units")
	for unit in units:
		unit.connect("was_selected", self, "_on_selected")
		unit.connect("was_deselected", self, "_on_deselected")

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			if $CanvasLayer/UnitPicker/Farmer/Frame.visible:
				var farmer = load_farmer.instance()
				farmer.position = event.position
				$TurnQueue/Player/Units.add_child(farmer)
				$CanvasLayer/UnitPicker/Farmer/Frame.visible = false
				
func create_info(body):
	$CanvasLayer/Info/NinePatchRect.rect_size = Vector2(get_viewport_rect().size.x,get_viewport_rect().size.y/4)
	$CanvasLayer/Info/NinePatchRect.rect_position = Vector2(0,-get_viewport_rect().size.y/4)
	#creating a sprite representing the unit
	unit_icon.texture = body.get_node("Sprite").texture
	#creating a label representing unit's name
	unit_name.text = body.name
	#creating a label representing unit's description
	if "Farmer" in body.name:
		unit_desc.text = "A farmer likes to farm. Has a lot of farms."

func _on_selected(body):
	$CanvasLayer/UnitPicker.visible = false	
	unit_info.visible = true
	create_info(body)

func _on_deselected(body):
	$CanvasLayer/UnitPicker.visible = true	
	delete_info()
	
func delete_info():
		unit_info.visible = false


func _on_Farmer_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			selected_unit = "Farmer"
			$CanvasLayer/UnitPicker/Farmer/Frame.visible = not $CanvasLayer/UnitPicker/Farmer/Frame.visible
