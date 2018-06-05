# Representation of a flat-topped hexagonal grid.
#
# The hex grid uses +x => NE and +y => N.
# The projected plane uses +x => E and +y => S,
# because this maps closest to Godot's 2D axes, and also x/z in 3D.
#
extends Node

var HexCell = preload("./HexCell.gd").new()

# Allow the user to scale the hex for fake perspective or somesuch
export(Vector2) var hex_scale = Vector2(1, 1) setget set_hex_scale

var base_hex_size = Vector2(1, sqrt(3)/2)
var hex_size
var hex_transform
var hex_transform_inv


func _init():
	set_hex_scale(hex_scale)


func set_hex_scale(scale):
	# We need to recalculate some stuff when projection scale changes
	hex_scale = scale
	hex_size = base_hex_size * hex_scale
	hex_transform = Transform2D(
		Vector2(hex_size.x * 3/4, -hex_size.y / 2),
		Vector2(0, -hex_size.y),
		Vector2(0, 0)
	)
	hex_transform_inv = hex_transform.affine_inverse()
	

func get_hex_center(hex):
	# Returns hex's centre position on the projection plane
	hex = HexCell.create_hex(hex)
	return hex_transform * hex.axial_coords
	
func get_hex_at(coords):
	# Returns a HexCell at the given Vector2 on the projection plane
	return HexCell.create_hex(hex_transform_inv * coords)
	
