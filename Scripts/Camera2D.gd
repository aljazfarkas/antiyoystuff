extends Camera2D

#https://godotengine.org/qa/3761/example-or-algorithm-for-pinch-zoom
onready var tilemap = get_parent().get_node("HexTiles")
onready var tile_size = tilemap.cell_size

var first_distance = 0
var events={}
var percision = 10
var current_zoom
export (Vector2) var maximum_zoomin = Vector2(0.05,0.05)
export (Vector2) var minimum_zoomout = Vector2(1,1)
var center

func _ready():
	set_process_unhandled_input(true)
	limit_bottom = (tile_size.y * tilemap.get_height())/2
	limit_top = -(tile_size.y * tilemap.get_height())/2
	limit_left = -(tile_size.x * tilemap.get_width())/2
	limit_right = (tile_size.x * tilemap.get_width())/2
	

func is_zooming():
	return events.size()>1

func dist() -> Vector2:
	var first_event =null
	var result 
	for event in events:
		if first_event!=null:
			result = events[event].position.distance_to(first_event.position)
			break
		first_event = events[event]
	return result

func center() -> Vector2:
	var first_event =null
	var result 
	for event in events:
		if first_event!=null:
			result = (map_pos(events[event].position) + map_pos(first_event))/2
			break
		first_event = events[event].position
	return result

func map_pos(position):
	var mtx = get_viewport().get_canvas_transform()
	var mt = mtx.affine_inverse()
	var p = mt.xform(position)
	return p 

func _unhandled_input(event):
	if event is InputEventScreenTouch and event.is_pressed():
		events[event.index]=event
		if events.size()>1:
			current_zoom=get_zoom()
			first_distance = dist()
			center = center()
	elif event is InputEventScreenTouch and not event.is_pressed():
		events.erase(event.index)
	elif event is InputEventScreenDrag:
		events[event.index] = event
		if events.size()>1:
			var second_distance = dist()
			if abs(first_distance-second_distance)>percision:
				var new_zoom =Vector2(first_distance/second_distance,first_distance/second_distance)
				var zoom = new_zoom*current_zoom
				if zoom<minimum_zoomout and zoom>maximum_zoomin:
					set_zoom(zoom)
				elif zoom>minimum_zoomout:
					set_zoom(minimum_zoomout)
				elif zoom<maximum_zoomin:
					set_zoom(maximum_zoomin)
#				set_global_position(center)
	elif events.size()==1 and event is InputEventMouseMotion:
		set_global_position(get_global_position()-event.get_relative()*get_zoom()*2)