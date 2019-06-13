tool
extends EditorPlugin

func _enter_tree():
	# Initialization of the plugin goes here
	# Add the new type with a name, a parent type, a script and an icon
	add_custom_type("HexCell", "Node", preload("HexCell.gd"), preload("icon_hex_cell.svg"))
	add_custom_type("HexGrid", "Node", preload("HexGrid.gd"), preload("icon_hex_grid.svg"))

func _exit_tree():
	# Clean-up of the plugin goes here
	# Always remember to remove it from the engine when deactivated
	remove_custom_type("HexGrid")
	remove_custom_type("HexCell")