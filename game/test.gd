extends Spatial

var HexCell = preload("res://HexCell.gd")

func _ready():
	var cell = HexCell.new()
	print("CUBE", cell.cube_coords)
	print("AXIAL", cell.axial_coords)
	print("OFFSET", cell.offset_coords)
	pass
