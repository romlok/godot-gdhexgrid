"""
	A converter between hex and Godot-space coordinate systems.
	
	The hex grid uses +x => NE and +y => N, whereas
	the projection to Godot-space uses +x => E, +y => S.
	
	We map hex coordinates to Godot-space with +y flipped to be the down vector
	so that it maps neatly to both Godot's 2D coordinate system, and also to
	x,z planes in 3D space.
	
	
	## Usage:
	
	#### var hex_scale = Vector2(...)

		If you want your hexes to display larger than the default 1 x 0.866 units,
		then you can customise the scale of the hexes using this property.
	
	#### func get_hex_center(hex)
	
		Returns the Godot-space coordinate of the center of the given hex coordinates.
		
		The coordinates can be given as either a HexCell instance; a Vector3 cube
		coordinate, or a Vector2 axial coordinate.
	
	#### func get_hex_at(coords)
	
		Returns HexCell whose grid position contains the given Godot-space coordinates.
	

"""
extends Node

var HexCell = preload("./HexCell.gd")

# Allow the user to scale the hex for fake perspective or somesuch
export(Vector2) var hex_scale = Vector2(1, 1) setget set_hex_scale

var base_hex_size = Vector2(1, sqrt(3)/2)
var hex_size
var hex_transform
var hex_transform_inv
# Pathfinding obstacles {Vector2: cost}
# A zero cost means impassable
var path_obstacles = {}
var path_bounds = Rect2()


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
	

"""
	Converting between hex-grid and 2D spatial coordinates
"""
func get_hex_center(hex):
	# Returns hex's centre position on the projection plane
	hex = HexCell.new(hex)
	return hex_transform * hex.axial_coords
	
func get_hex_at(coords):
	# Returns a HexCell at the given Vector2 on the projection plane
	return HexCell.new(hex_transform_inv * coords)
	

"""
	Pathfinding
"""
func set_bounds(rect):
	# Set the absolute bounds of the pathfinding area
	path_bounds = Rect2(rect.position, rect.size)
	
func get_obstacles():
	return path_obstacles
	
func add_obstacles(val, cost=0):
	# Store the given coordinate/s as obstacles
	if not typeof(val) == TYPE_ARRAY:
		val = [val]
	for coords in val:
		path_obstacles[Vector2(coords.x, coords.y)] = cost
	
func get_path(from, to, exceptions=[]):
	# Light a starry path
	## TODO
	return []
