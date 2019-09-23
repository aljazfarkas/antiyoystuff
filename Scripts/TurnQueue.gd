extends Node2D

class_name TurnQueue

var active_charachter

func initialize():
	active_charachter = get_child(0)
	
func play_turn():
	yield(active_charachter.play_turn(),"completed")
	var new_index : int = (active_charachter.get_index() + 1) % get_child_count()
	active_charachter = get_child(new_index)