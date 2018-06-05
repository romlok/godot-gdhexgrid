# Script to attach to a node which represents a hex grid
extends Node2D

var HexGrid = preload("./HexGrid.gd").new()

export(NodePath) var area_coords = NodePath("AreaCoords")
export(NodePath) var hex_coords = NodePath("HexCoords")
export(NodePath) var highlight = NodePath("Highlight")


func _ready():
	area_coords = get_node(area_coords)
	hex_coords = get_node(hex_coords)
	highlight = get_node(highlight)
	if highlight != null:
		# Work out the scale from the highlight size
		HexGrid.hex_scale = highlight.scale
	

func _unhandled_input(event):
	if event.position:
		var relative_pos = self.transform.affine_inverse() * event.position
		# Display the coords used
		if area_coords != null:
			area_coords.text = str(relative_pos)
		if hex_coords != null:
			hex_coords.text = str(HexGrid.get_hex_at(relative_pos).axial_coords)
		
		# Snap the highlight to the nearest grid cell
		if highlight != null:
			highlight.position = HexGrid.get_hex_center(HexGrid.get_hex_at(relative_pos))
