# A hexagonal grid cell
#
# Ref: https://www.redblobgames.com/grids/hexagons/
#
# The hexes use a flat-topped orientation,
# the axial coordinates use +y => N, +x => SE,
# and offset coords have odd rows shifted up half a step.
#
# Using y instead of z makes following the reference more tricky,
# but is more consistent with Godot's Vector2 objects (which have x and y).

extends Node

# We use unit-size flat-topped hexes
const size = Vector2(1, sqrt(3)/2)

# Cube coords are definitive
var cube_coords = Vector3() setget set_coords
# but other coord systems can be used
var axial_coords setget set_coords, get_axial_coords
var offset_coords setget set_offset_coords, get_offset_coords

func set_coords(val):
	if typeof(val) == TYPE_VECTOR3:
		# Good ol' cube coords
		assert(val.x + val.y + val.z == 0)
		cube_coords = val
	elif typeof(val) == TYPE_VECTOR2:
		# Convert from axial coords
		cube_coords = Vector3(val.x, val.y, -val.x - val.y)
	else:
		# Do nothing if we get some unhandled value
		printerr("Invalid HexCell coordinates: ", val)
	
func get_axis_coords():
	# Just convert the cube coords
	return Vector2(cube_coords.x, cube_coords.y)
	
func get_offset_coords():
	# Convert from cube to offset
	var off_y = cube_coords.y + (cube_coords.x - (cube_coords.x % 2)) /2
	return Vector2(cube_coords.x, off_y)
	
func set_offset_coords(val):
	# Convert from offset to cube
	var cube_y = val.y - (val.x - (val.x % 2)) / 2
	self.set_coords(Vector2(val.x, cube_y))
	