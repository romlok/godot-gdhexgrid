extends "res://addons/gut/test.gd"

var HexCell = load("res://HexCell.gd")
var HexGrid = load("res://HexGrid.gd")
var grid
var map
# This is the hex map we'll test with:
# remember: +y is N, +x is NE
"""
	                     .
	                  .
	               .     .
	            .     .
	         .     .     .
	      .     .     .
	   .     .     .     .
	.     O     B     .
	   OF    O     .     C
	.     E     O     .
	   O     O     D
	.     O     .
	   .     .
	.     A
	   G
	. <- (0, 0)
"""
var a_pos = Vector2(2, 0)
var b_pos = Vector2(4, 2)
var c_pos = Vector2(7, 0)
var d_pos = Vector2(5, 0)
var e_pos = Vector2(2, 2)
var f_pos = Vector2(1, 3)
var g_pos = Vector2(1, 0)
var obstacles = [
	Vector2(2, 1),
	Vector2(3, 1),
	Vector2(4, 1),
	Vector2(1, 2),
	Vector2(3, 2),
	Vector2(1, 3),
	Vector2(2, 3),
]

func setup():
	grid = HexGrid.new()
	grid.set_bounds(Vector2(0, 0), Vector2(7, 4))
	grid.add_obstacles(obstacles)

func test_bounds():
	# Push the boundaries
	# Check that the test boundary works properly
	assert_eq(grid.get_hex_cost(Vector2(0, 0)), grid.path_cost_default, "SW is open")
	assert_eq(grid.get_hex_cost(Vector2(0, 4)), grid.path_cost_default, "W is open")
	assert_eq(grid.get_hex_cost(Vector2(7, 0)), grid.path_cost_default, "E is open")
	assert_eq(grid.get_hex_cost(Vector2(7, 4)), grid.path_cost_default, "NE is open")
	assert_eq(grid.get_hex_cost(Vector2(8, 2)), 0, "Too much X is blocked")
	assert_eq(grid.get_hex_cost(Vector2(6, 5)), 0, "Too much Y is blocked")
	assert_eq(grid.get_hex_cost(Vector2(-1, 2)), 0, "Too little X is blocked")
	assert_eq(grid.get_hex_cost(Vector2(6, -1)), 0, "Too little Y is blocked")
func test_negative_bounds():
	# Test negative space
	grid = HexGrid.new()
	grid.set_bounds(Vector2(-5, -5), Vector2(-2, -2))
	assert_eq(grid.get_hex_cost(Vector2(-2, -2)), grid.path_cost_default)
	assert_eq(grid.get_hex_cost(Vector2(-5, -5)), grid.path_cost_default)
	assert_eq(grid.get_hex_cost(Vector2(0, 0)), 0)
	assert_eq(grid.get_hex_cost(Vector2(-6, -3)), 0)
	assert_eq(grid.get_hex_cost(Vector2(-3, -1)), 0)
func test_roundabounds():
	# We can also go both ways
	grid.set_bounds(Vector2(-3, -3), Vector2(2, 2))
	assert_eq(grid.get_hex_cost(Vector2(-3, -3)), grid.path_cost_default)
	assert_eq(grid.get_hex_cost(Vector2(2, 2)), grid.path_cost_default)
	assert_eq(grid.get_hex_cost(Vector2(0, 0)), grid.path_cost_default)
	assert_eq(grid.get_hex_cost(Vector2(-4, 0)), 0)
	assert_eq(grid.get_hex_cost(Vector2(0, 3)), 0)
	
func test_grid_obstacles():
	# Make sure we can obstacleize the grid
	assert_eq(grid.get_obstacles().size(), obstacles.size())
	# Test adding via a HexCell instance
	grid.add_obstacles(HexCell.new(Vector2(0, 0)))
	assert_eq(grid.get_obstacles()[Vector2(0, 0)], 0)
	# Test replacing an obstacle
	grid.add_obstacles(Vector2(0, 0), 2)
	assert_eq(grid.get_obstacles()[Vector2(0, 0)], 2)
	# Test removing an obstacle
	grid.remove_obstacles(Vector2(0, 0))
	assert_does_not_have(grid.get_obstacles(), Vector2(0, 0))
	# Make sure removing a non-obstacle doesn't error
	grid.remove_obstacles(Vector2(0, 0))
	
func test_grid_barriers():
	# Make sure we can barrier things on the grid
	assert_eq(grid.get_barriers().size(), 0)
	# Add a barrier
	var coords = Vector2(0, 0)
	var barriers = grid.get_barriers()
	grid.add_barriers(coords, HexCell.DIR_N)
	assert_eq(barriers.size(), 1)
	assert_has(barriers, coords)
	assert_eq(barriers[coords].size(), 1)
	assert_has(barriers[coords], HexCell.DIR_N)
	# Overwrite the barrier
	grid.add_barriers(coords, HexCell.DIR_N, 1337)
	assert_eq(barriers[coords][HexCell.DIR_N], 1337)
	# Add more barrier to the hex
	grid.add_barriers(coords, [HexCell.DIR_S, HexCell.DIR_NE])
	assert_eq(barriers[coords].size(), 3)
	assert_has(barriers[coords], HexCell.DIR_N)
	# Remove part of the hex's barrier
	grid.remove_barriers(coords, [HexCell.DIR_N])
	assert_eq(barriers[coords].size(), 2)
	assert_does_not_have(barriers[coords], HexCell.DIR_N)
	assert_has(barriers[coords], HexCell.DIR_S)
	assert_has(barriers[coords], HexCell.DIR_NE)
	# Remove all the hex's barriers
	grid.remove_barriers(coords)
	assert_eq(barriers.size(), 0)
	# Remove no barrier with no error
	grid.remove_barriers([Vector2(1, 1), Vector2(2, 2)])
	

func test_hex_costs():
	# Test that the price is right
	assert_eq(grid.get_hex_cost(HexCell.new(Vector2(1, 1))), grid.path_cost_default, "Open hex is open")
	assert_eq(grid.get_hex_cost(Vector3(2, 1, -3)), 0, "Obstacle being obstructive")
	# Test partial obstacle
	grid.add_obstacles(Vector2(1, 1), 1.337)
	assert_eq(grid.get_hex_cost(Vector2(1, 1)), 1.337, "9")
	
func test_move_costs():
	# Test that more than just hex costs are at work
	assert_eq(grid.get_move_cost(Vector2(0, 0), HexCell.DIR_N), grid.path_cost_default)
func test_move_cost_barrier():
	# Put up a barrier
	grid.add_barriers(Vector2(0, 0), HexCell.DIR_N)
	assert_eq(grid.get_move_cost(Vector2(0, 0), HexCell.DIR_N), 0)
func test_move_cost_barrier_backside():
	# The destination has a barrier
	grid.add_barriers(Vector2(0, 1), HexCell.DIR_S)
	assert_eq(grid.get_move_cost(Vector2(0, 0), HexCell.DIR_N), 0)
func test_move_cost_cumulative():
	# Test that moving adds up hex and barrier values
	# But NOT from the *starting* hex!
	grid.add_obstacles(Vector2(0, 0), 1)
	grid.add_obstacles(Vector2(0, 1), 2)
	grid.add_barriers(Vector2(0, 0), HexCell.DIR_N, 4)
	grid.add_barriers(Vector2(0, 1), HexCell.DIR_S, 8)
	assert_eq(grid.get_move_cost(Vector2(0, 0), HexCell.DIR_N), 14)
	

func check_path(got, expected):
	# Assert that the gotten path was the expected route
	assert_eq(got.size(), expected.size(), "Path should be as long as expected")
	for idx in range(min(got.size(), expected.size())):
		var hex = got[idx]
		var check = expected[idx]
		if typeof(check) == TYPE_ARRAY:
			# In case of multiple valid paths
			assert_has(check, hex.axial_coords)
		else:
			assert_eq(check, hex.axial_coords)
		
func test_straight_line():
	# Path between A and C is straight
	var path = [
		a_pos,
		Vector2(3, 0),
		Vector2(4, 0),
		Vector2(5, 0),
		Vector2(6, 0),
		c_pos,
	]
	check_path(grid.find_path(a_pos, c_pos), path)
	
func test_wonky_line():
	# Path between B and C is a bit wonky
	var path = [
		b_pos,
		[Vector2(5, 1), Vector2(5, 2)],
		[Vector2(6, 0), Vector2(6, 1)],
		c_pos,
	]
	check_path(grid.find_path(HexCell.new(b_pos), HexCell.new(c_pos)), path)
	
func test_obstacle():
	# Path between A and B should go around the bottom
	var path = [
		a_pos,
		Vector2(3, 0),
		Vector2(4, 0),
		Vector2(5, 0),
		Vector2(5, 1),
		b_pos,
	]
	check_path(grid.find_path(a_pos, b_pos), path)
	
func test_walls():
	# Test that we can't walk through walls
	var walls = [
		HexCell.DIR_N,
		HexCell.DIR_NE,
		HexCell.DIR_SE,
		HexCell.DIR_S,
		# DIR_SE is the only opening
		HexCell.DIR_NW,
	]
	grid.add_barriers(g_pos, walls)
	var path = [
		a_pos,
		Vector2(1, 1),
		Vector2(0, 1),
		Vector2(0, 0),
		g_pos,
	]
	check_path(grid.find_path(a_pos, g_pos), path)
	
func test_slopes():
	# Test that we *can* walk through *some* walls
	# A barrier which is passable, but not worth our hex
	grid.add_barriers(g_pos, HexCell.DIR_NE, 3)
	# A barrier which is marginally better than moving that extra hex
	grid.add_barriers(g_pos, HexCell.DIR_N, grid.path_cost_default - 0.1)
	var path = [
		a_pos,
		Vector2(1, 1),
		g_pos,
	]
	check_path(grid.find_path(a_pos, g_pos), path)
	
func test_rough_terrain():
	# Path between A and B depends on the toughness of D
	var short_path = [
		a_pos,
		Vector2(3, 0),
		Vector2(4, 0),
		d_pos,
		Vector2(5, 1),
		b_pos,
	]
	var long_path = [
		a_pos,
		Vector2(1, 1),
		Vector2(0, 2),
		Vector2(0, 3),
		Vector2(0, 4),
		Vector2(1, 4),
		Vector2(2, 4),
		Vector2(3, 3),
		b_pos,
	]
	# The long path is 9 long, the short 6,
	# so it should take the long path once d_pos costs more than 3 over default
	var tests = {
		grid.path_cost_default: short_path,
		grid.path_cost_default + 1: short_path,
		grid.path_cost_default + 2.9: short_path,
		grid.path_cost_default + 3.1: long_path,
		grid.path_cost_default + 50: long_path,
		0: long_path,
	}
	for cost in tests:
		grid.add_obstacles(d_pos, cost)
		check_path(grid.find_path(a_pos, b_pos), tests[cost])
	
func test_exception():
	# D is impassable, so path between A and B should go around the top as well
	var path = [
		a_pos,
		Vector2(1, 1),
		Vector2(0, 2),
		Vector2(0, 3),
		Vector2(0, 4),
		Vector2(1, 4),
		Vector2(2, 4),
		Vector2(3, 3),
		b_pos,
	]
	check_path(grid.find_path(a_pos, b_pos, [d_pos]), path)
func test_exception_hex():
	# Same as the above, but providing an exceptional HexCell instance
	var path = [
		a_pos,
		Vector2(1, 1),
		Vector2(0, 2),
		Vector2(0, 3),
		Vector2(0, 4),
		Vector2(1, 4),
		Vector2(2, 4),
		Vector2(3, 3),
		b_pos,
	]
	check_path(grid.find_path(a_pos, b_pos, [HexCell.new(d_pos)]), path)
	
func test_exceptional_goal():
	# If D is impassable, we should path to its neighbour
	var path = [
		a_pos,
		Vector2(3, 0),
		Vector2(4, 0),
	]
	check_path(grid.find_path(a_pos, d_pos, [d_pos]), path)
	
func test_inaccessible():
	# E is inaccessible!
	var path = grid.find_path(a_pos, e_pos)
	assert_eq(path.size(), 0)
	
func test_obstacle_neighbour():
	# Sometimes we can't get to something, but we can get next to it.
	var path = [
		a_pos,
		Vector2(1, 1),
		Vector2(0, 2),
		Vector2(0, 3),
	]
	check_path(grid.find_path(a_pos, f_pos), path)
	
func test_difficult_goal():
	# We should be able to path to a goal, no matter how difficult the final step
	grid.add_obstacles(f_pos, 1337)
	var path = [
		a_pos,
		Vector2(1, 1),
		Vector2(0, 2),
		Vector2(0, 3),
		f_pos,
	]
	check_path(grid.find_path(a_pos, f_pos), path)
	
