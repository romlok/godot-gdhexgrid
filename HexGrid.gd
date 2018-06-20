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
var path_cost_default = 1.0


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
	
	Ref: https://www.redblobgames.com/pathfinding/a-star/introduction.html
"""
func set_bounds(min_coords, max_coords):
	# Set the absolute bounds of the pathfinding area in grid coords
	# The given coords will be inside the boundary (hence the extra (1, 1))
	path_bounds = Rect2(min_coords, min_coords + max_coords + Vector2(1, 1))
	
func get_obstacles():
	return path_obstacles
	
func add_obstacles(val, cost=0):
	# Store the given coordinate/s as obstacles
	if not typeof(val) == TYPE_ARRAY:
		val = [val]
	for coords in val:
		path_obstacles[Vector2(coords.x, coords.y)] = cost
	
func get_cost(coords):
	# Returns the cost of moving to the given hex
	if coords in path_obstacles:
		return path_obstacles[coords]
	if not path_bounds.has_point(coords):
		# Out of bounds
		return 0
	return path_cost_default
	
	
func get_path(start, goal, exceptions=[]):
	# Light a starry path from the start to the goal, inclusive
	var frontier = [make_priority_item(start, 0)]
	var came_from = {start: null}
	var cost_so_far = {start: 0}
	while not frontier.empty():
		var current = frontier.pop_front().v
		if current == goal:
			break
		for next_hex in HexCell.new(current).get_all_adjacent():
			var next = next_hex.axial_coords
			var next_cost = get_cost(next)
			if not next_cost:
				# We shall not pass
				continue
			next_cost += cost_so_far[current]
			if not next in cost_so_far or next_cost < cost_so_far[next]:
				# New shortest path to that node
				cost_so_far[next] = next_cost
				var priority = next_cost + next_hex.distance_to(goal)
				# Insert into the frontier
				var item = make_priority_item(next, priority)
				var idx = frontier.bsearch_custom(item, self, "comp_priority_item")
				frontier.insert(idx, item)
				came_from[next] = current
	# Follow the path back where we came_from
	if not goal in came_from:
		# Not found
		return []
	var path = [HexCell.new(goal)]
	var current = goal
	while current != start:
		current = came_from[current]
		path.push_front(HexCell.new(current))
	return path
	
# Used to make a priority queue out of an array
func make_priority_item(val, priority):
	return {"v": val, "p": priority}
func comp_priority_item(a, b):
	return a.p < b.p
