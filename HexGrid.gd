"""
	A converter between hex and Godot-space coordinate systems.
	
	The hex grid uses +x => NE and +y => N, whereas
	the projection to Godot-space uses +x => E, +y => S.
	
	We map hex coordinates to Godot-space with +y flipped to be the down vector
	so that it maps neatly to both Godot's 2D coordinate system, and also to
	x,z planes in 3D space.
"""
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
	
