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

### HexCell

