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
	
	### Path-finding
	
	HexGrid also includes an implementation of the A* pathfinding algorithm.
	The class can be used to populate an internal representation of a game grid
	with obstacles to traverse.
	
	#### func set_bounds(min_coords, max_coords)
	
		Sets the hard outer limits of the path-finding grid.
		
		The coordinates given are the min and max corners *inside* a bounding
		square (diamond in hex visualisation) region. Any hex outside that area
		is considered an impassable obstacle.
		
		The default bounds consider only the origin to be inside, so you're probably
		going to want to do something about that.
	
	#### func get_obstacles()
	
		Returns a dict of all obstacles and their costs
		
		The keys are Vector2s of the axial coordinates, the values will be the
		cost value. Zero cost means an impassable obstacle.
	
	#### func add_obstacles(vals, cost=0)
	
		Adds one or more obstacles to the path-finding grid
		
		The given coordinates (axial or cube), HexCell instance, or array thereof,
		will be added as path-finding obstacles with the given cost. A zero cost
		indicates an impassable obstacle.
	
	#### func remove_obstacles(vals)
	
		Removes one or more obstacles from the path-finding grid
		
		The given coordinates (axial or cube), HexCell instance, or array thereof,
		will be removed as obstacles from the path-finding grid.
		
	#### func get_cost(coords)
	
		Returns the movement cost of the specified grid position.
	
	#### func get_path(start, goal, exceptions=[])
	
		Calculates an A* path from the start to the goal.
		
		Returns a list of HexCell instances charting the path from the given start
		coordinates to the goal, including both ends of the journey.
		
		Exceptions can be specified as the third parameter, and will act as
		impassable obstacles for the purposes of this call of the function.
		This can be used for pathing around obstacles which may change position
		(eg. enemy playing pieces), without having to update the grid's list of
		obstacles every time something moves.
		
		If the goal is an impassable location, the path will terminate at the nearest
		adjacent coordinate. In this instance, the goal hex will not be included in
		the returned array.
		
		If there is no path possible to the goal, or any hex adjacent to it, an
		empty array is returned. But the algorithm will only know that once it's
		visited every tile it can reach, so try not to path to the impossible.
	
"""
extends Resource

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
	
	We use axial coords for everything internally (to use Rect2.has_point),
	but the methods accept cube or axial coords, or HexCell instances.
"""
func set_bounds(min_coords, max_coords):
	# Set the absolute bounds of the pathfinding area in grid coords
	# The given coords will be inside the boundary (hence the extra (1, 1))
	min_coords = HexCell.new(min_coords).axial_coords
	max_coords = HexCell.new(max_coords).axial_coords
	path_bounds = Rect2(min_coords, (max_coords - min_coords) + Vector2(1, 1))
	
func get_obstacles():
	return path_obstacles
	
func add_obstacles(vals, cost=0):
	# Store the given coordinate/s as obstacles
	if not typeof(vals) == TYPE_ARRAY:
		vals = [vals]
	for coords in vals:
		coords = HexCell.new(coords).axial_coords
		path_obstacles[coords] = cost
	
func remove_obstacles(vals):
	# Remove the given obstacle/s from the grid
	if not typeof(vals) == TYPE_ARRAY:
		vals = [vals]
	for coords in vals:
		coords = HexCell.new(coords).axial_coords
		path_obstacles.erase(coords)
	
func get_cost(coords):
	# Returns the cost of moving to the given hex
	coords = HexCell.new(coords).axial_coords
	if coords in path_obstacles:
		return path_obstacles[coords]
	if not path_bounds.has_point(coords):
		# Out of bounds
		return 0
	return path_cost_default
	
	
func get_path(start, goal, exceptions=[]):
	# Light a starry path from the start to the goal, inclusive
	start = HexCell.new(start).axial_coords
	goal = HexCell.new(goal).axial_coords
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
			if not next_cost or next in exceptions:
				if next == goal:
					# Our goal is an obstacle, but we're next to it
					# so our work here is done
					came_from[next] = current
					frontier.clear()
					break
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
	if not goal in came_from:
		# Not found
		return []
	# Follow the path back where we came_from
	var path = []
	if not (goal in path_obstacles or goal in exceptions):
		# We only include the goal if we can path there
		path.append(HexCell.new(goal))
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
