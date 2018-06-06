# GDHexGrid

Tools for using hexagonal grids in GDScript.

The reference used for creating this was the amazing guide:
https://www.redblobgames.com/grids/hexagons/

Copyright 2018 Mel Collins.
Distributed under the MIT license (see LICENSE.txt).

## Orientation

There are many ways to orient a hex grid, this library was written
using the following assumptions:

* The hexes use a flat-topped orientation;
* Axial coordinates use +x => NE; +y => N;
* Offset coords have odd rows shifted up half a step;
* Projections of the hex grid into Godot-space use +x => E, +y => S.

Using x,y instead of the reference's preferred x,z for axial coords makes
following along with the reference a little more tricky, but is less confusing
when using Godot's Vector2(x, y) objects.

We map hex coordinates to Godot-space with +y flipped to be the down vector
so that it maps neatly to both Godot's 2D coordinate system, and also to
x,z planes in 3D space.


## Usage

### HexGrid

HexGrid is used when you want to position hexes in a 2D or 3D scene.
It translates coordinates between the hex grid and conventional spaces.

#### var hex_scale = Vector2(...)

If you want your hexes to display larger than the default 1 x 0.866 units,
then you can customise the scale of the hexes using this property.

#### func get_hex_center(hex)

Returns the Godot-space coordinate of the center of the given hex coordinates.

The coordinates can be given as either a HexCell instance; a Vector3 cube
coordinate, or a Vector2 axial coordinate.

#### func get_hex_at(coords)

Returns HexCell whose grid position contains the given Godot-space coordinates.


### HexCell

A HexCell represents a single hex in the grid, and is the meat of the library.

#### var cube_coords; var axial_coords; var offset_coords

Cube coordinates are used internally as the canonical representation, but
both axial and offset coordinates can be read and modified through these
properties.

#### func get_adjacent(direction)

Returns the neighbouring HexCell in the given direction.

The direction should be one of the DIR_N, DIR_NE, DIR_SE, DIR_S, DIR_SW, or
DIR_NW constants provided by the HexCell class.

#### func get_all_adjacent()

Returns an array of the six HexCell instances neighbouring this one.

#### func get_all_within(distance)

Returns an array of all the HexCells within the given number of steps,
including the current hex.

#### func get_ring(distance)

Returns an array of all the HexCells at the given distance from the current.

#### func distance_to(target)

Returns the number of hops needed to get from this hex to the given target.

The target can be supplied as either a HexCell instance, cube or axial
coordinates.

#### func line_to(target)

Returns an array of all the hexes crossed when drawing a straight line
between this hex and another.

The target can be supplied as either a HexCell instance, cube or axial
coordinates.

The items in the array will be in the order of traversal, and include both
the start (current) hex, as well as the final target.

