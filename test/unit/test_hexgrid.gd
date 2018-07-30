extends "res://addons/gut/test.gd"

var HexCell = load("res://HexCell.gd")
var HexGrid = load("res://HexGrid.gd")
var cell
var grid
var w
var h

func setup():
	cell = HexCell.new()
	grid = HexGrid.new()
	w = grid.hex_size.x
	h = grid.hex_size.y
	

func test_hex_to_projection():
	var tests = {
		# Remember, projection +y => S
		Vector2(0, 0): Vector2(0, 0),
		Vector2(0, 1): Vector2(0, -h),
		Vector2(1, 0): Vector2(w*0.75, -h/2),
		Vector2(-4, -3): Vector2(4 * (-w*0.75), (3 * h) + (4 * h / 2)),
	}
	for hex in tests:
		assert_eq(tests[hex], grid.get_hex_center(hex))
	
func test_hex_to_projection_scaled():
	grid.set_hex_scale(Vector2(2, 2))
	var tests = {
		Vector2(0, 0): Vector2(0, 0),
		Vector2(0, 1): 2 * Vector2(0, -h),
		Vector2(1, 0): 2 * Vector2(w * 0.75, -h/2),
		Vector2(-4, -3): 2 * Vector2(4 * (-w * 0.75), (3 * h) + (4 * h / 2)),
	}
	for hex in tests:
		assert_eq(tests[hex], grid.get_hex_center(hex))
	
func test_hex_to_projection_squished():
	grid.set_hex_scale(Vector2(2, 1))
	var tests = {
		Vector2(0, 0): Vector2(0, 0),
		Vector2(0, 1): Vector2(0, -h),
		Vector2(1, 0): Vector2(2 * w * 0.75, -h/2),
		Vector2(-4, -3): Vector2(2 * 4 * (-w * 0.75), (3 * h) + (4 * h / 2)),
	}
	for hex in tests:
		assert_eq(tests[hex], grid.get_hex_center(hex))
	
func test_hex_to_3d_projection():
	var tests = {
		Vector2(0, 0): Vector3(0, 0, 0),
		Vector2(0, 1): Vector3(0, 0, -h),
		Vector2(1, 0): Vector3(w*0.75, 0, -h/2),
		Vector2(-4, -3): Vector3(4 * (-w*0.75), 0, (3 * h) + (4 * h / 2)),
	}
	for hex in tests:
		assert_eq(tests[hex], grid.get_hex_center3(hex))
	# Also test the second parameter
	assert_eq(
		Vector3(0, 1.2, 0),
		grid.get_hex_center3(Vector2(0, 0), 1.2)
	)
	

func test_projection_to_hex():
	var tests = {
		Vector2(0, 0): Vector2(0, 0),
		Vector2(w / 2 - 0.01, 0): Vector2(0, 0),
		Vector2(w / 2 - 0.01, h / 2): Vector2(1, -1),
		Vector2(w / 2 - 0.01, -h / 2): Vector2(1, 0),
		Vector2(0, h): Vector2(0, -1),
		Vector2(-w - 0.01, 0): Vector2(-2, 1),
		Vector2(-w, 0.01): Vector2(-1, 0),
		Vector2(-w, -0.01): Vector2(-1, 1),
		# Also Vector3s are valid input
		Vector3(0, 0, 0): Vector2(0, 0),
		Vector3(w / 2 - 0.01, 12, h / 2): Vector2(1, -1),
	}
	for coords in tests:
		assert_eq(tests[coords], grid.get_hex_at(coords).axial_coords)
	
func test_projection_to_hex_doublesquished():
	grid.set_hex_scale(Vector2(4, 2))
	var tests = {
		Vector2(0, 0): Vector2(0, 0),
		Vector2(4 * w / 2 - 0.01, 0): Vector2(0, 0),
		Vector2(4 * w / 2 - 0.01, h / 2): Vector2(1, -1),
		Vector2(4 * w / 2 - 0.01, -h / 2): Vector2(1, 0),
		Vector2(0, 2 * h): Vector2(0, -1),
		Vector2(4 * -w - 0.01, 0): Vector2(-2, 1),
		Vector2(4 * -w, 0.01): Vector2(-1, 0),
		Vector2(4 * -w, -0.01): Vector2(-1, 1),
	}
	for coords in tests:
		assert_eq(tests[coords], grid.get_hex_at(coords).axial_coords)
	
