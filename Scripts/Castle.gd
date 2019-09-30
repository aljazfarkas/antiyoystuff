extends Buildings

func _ready():
	self.global_position = self.global_position.snapped(tile_size)