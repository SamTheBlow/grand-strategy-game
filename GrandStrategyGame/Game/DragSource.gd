extends ColorRect

signal dragged

# This emits a signal if there is a mouse click inside of this node's rectangle.
# In the future, it would be nice to be able to check for a mouse click
# on things other than a rectangle.
func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_position = get_viewport().get_mouse_position()
		if is_visible_in_tree() and mouse_position.x >= global_position.x and mouse_position.x <= global_position.x + size.x and mouse_position.y >= global_position.y and mouse_position.y <= global_position.y + size.y:
			get_viewport().set_input_as_handled()
			emit_signal("dragged")
