# A hexagonal grid cell
#
# Ref: https://www.redblobgames.com/grids/hexagons/
#
# The hexes use a flat-topped orientation,
# the axial coordinates use +y => N, +x => NE,
# and offset coords have odd rows shifted up half a step.
#
# Using y instead of z makes following the reference more tricky,
# but is more consistent with Godot's Vector2 objects (which have x and y).

extends Node

# We use unit-size flat-topped hexes
const size = Vector2(1, sqrt(3)/2)

# Cube coords are definitive
# We use an array of ints because vectors are all floats,
# which can result in precision errors over time.
var cube_coords = [0, 0, 0] setget set_cube_coords, get_cube_coords
# other coord systems can be used
var axial_coords setget set_axial_coords, get_axial_coords
var offset_coords setget set_offset_coords, get_offset_coords


func get_cube_coords():
	# Returns a Vector3 of the cube coordinates
	return Vector3(cube_coords[0], cube_coords[1], cube_coords[2])
	
func set_cube_coords(val):
	# Sets the position from a Vector3 or a 3-array of cube coordinates
	if typeof(val) == TYPE_VECTOR3:
		val = [int(val.x), int(val.y), int(val.z)]
	assert(val[0] + val[1] + val[2] == 0)
	cube_coords = val
	
func get_axial_coords():
	# Returns a Vector2 of the axial coordinates
	return Vector2(cube_coords[0], cube_coords[1])
	
func set_axial_coords(val):
	# Sets position from a Vector2 of axial coordinates
	var x = int(val.x)
	var y = int(val.y)
	cube_coords = [x, y, -x - y]
	
func get_offset_coords():
	# Returns a Vector2 of the offset coordinates
	var x = cube_coords[0]
	var y = cube_coords[1]
	var off_y = y + (x - (x & 1)) / 2
	return Vector2(x, off_y)
	
func set_offset_coords(val):
	# Sets position from a Vector2 of offset coordinates
	var x = int(val.x)
	var y = int(val.y)
	var cube_y = y - (x - (x & 1)) / 2
	self.set_axial_coords(Vector2(x, cube_y))
	