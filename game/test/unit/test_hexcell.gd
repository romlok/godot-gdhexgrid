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
		
	
class TestAdjacent:
	extends "res://addons/gut/test.gd"
	
	var HexCell = load("res://HexCell.gd")
	var cell
	
	func setup():
		cell = HexCell.new()
		cell.axial_coords = Vector2(1, 2)
	
	func test_adjacent():
		var foo = cell.get_adjacent(HexCell.DIR_N)
		assert_eq(foo.axial_coords, Vector2(1, 3))
		foo = cell.get_adjacent(HexCell.DIR_NE)
		assert_eq(foo.axial_coords, Vector2(2, 2))
		foo = cell.get_adjacent(HexCell.DIR_SE)
		assert_eq(foo.axial_coords, Vector2(2, 1))
		foo = cell.get_adjacent(HexCell.DIR_S)
		assert_eq(foo.axial_coords, Vector2(1, 1))
		foo = cell.get_adjacent(HexCell.DIR_SW)
		assert_eq(foo.axial_coords, Vector2(0, 2))
		foo = cell.get_adjacent(HexCell.DIR_NW)
		assert_eq(foo.axial_coords, Vector2(0, 3))
	func test_not_really_adjacent():
		var foo = cell.get_adjacent(Vector3(-3, -3, 6))
		assert_eq(foo.axial_coords, Vector2(-2, -1))
	func test_adjacent_axial():
		var foo = cell.get_adjacent(Vector2(1, 1))
		assert_eq(foo.axial_coords, Vector2(2, 3))
		
	func test_all_adjacent():
		var coords = []
		for foo in cell.get_all_adjacent():
			coords.append(foo.axial_coords)
		assert_has(coords, Vector2(1, 3))
		assert_has(coords, Vector2(2, 2))
		assert_has(coords, Vector2(2, 1))
		assert_has(coords, Vector2(1, 1))
		assert_has(coords, Vector2(0, 2))
		assert_has(coords, Vector2(0, 3))
		
	
