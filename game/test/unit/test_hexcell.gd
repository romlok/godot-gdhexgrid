extends "res://addons/gut/test.gd"

class TestCoords:
	extends "res://addons/gut/test.gd"
	
	var HexCell = load("res://HexCell.gd")
	var cell
	
	func setup():
		cell = HexCell.new()
		
	
	func test_from_cubic_positive():
		cell.cube_coords = Vector3(2, 1, -3)
		assert_eq(cell.cube_coords, Vector3(2, 1, -3))
		assert_eq(cell.axial_coords, Vector2(2, 1))
		assert_eq(cell.offset_coords, Vector2(2, 2))
	func test_from_cubic_negative():
		cell.cube_coords = Vector3(-1, -1, 2)
		assert_eq(cell.cube_coords, Vector3(-1, -1, 2))
		assert_eq(cell.axial_coords, Vector2(-1, -1))
		assert_eq(cell.offset_coords, Vector2(-1, -2))
	func test_from_cubic_invalid():
		cell.cube_coords = Vector3(1, 2, 3)
		assert_eq(cell.cube_coords, Vector3(0, 0, 0))
		
	func test_from_axial_positive():
		cell.axial_coords = Vector2(2, 1)
		assert_eq(cell.cube_coords, Vector3(2, 1, -3))
		assert_eq(cell.axial_coords, Vector2(2, 1))
		assert_eq(cell.offset_coords, Vector2(2, 2))
	func test_from_axial_negative():
		cell.axial_coords = Vector2(-1, -1)
		assert_eq(cell.cube_coords, Vector3(-1, -1, 2))
		assert_eq(cell.axial_coords, Vector2(-1, -1))
		assert_eq(cell.offset_coords, Vector2(-1, -2))
		
	func test_from_offset_positive():
		cell.offset_coords = Vector2(2, 2)
		assert_eq(cell.cube_coords, Vector3(2, 1, -3))
		assert_eq(cell.axial_coords, Vector2(2, 1))
		assert_eq(cell.offset_coords, Vector2(2, 2))
	func test_from_offset_negative():
		cell.offset_coords = Vector2(-1, -2)
		assert_eq(cell.cube_coords, Vector3(-1, -1, 2))
		assert_eq(cell.axial_coords, Vector2(-1, -1))
		assert_eq(cell.offset_coords, Vector2(-1, -2))
		
	
