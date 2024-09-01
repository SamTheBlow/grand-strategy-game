extends ColorRect
## The node responsible for detecting your mouse click
## for the purpose of [Draggable] objects.
##
## Emits a signal if there is a mouse click inside of this node's rectangle.
# TODO be able to check for a mouse click on things other than a rectangle


signal dragged()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_typed := event as InputEventMouseButton
		if (
				event_typed.pressed
				and event_typed.button_index == MOUSE_BUTTON_LEFT
		):
			var mouse_position: Vector2 = get_viewport().get_mouse_position()
			if (
					is_visible_in_tree()
					and mouse_position.x >= global_position.x
					and mouse_position.x <= global_position.x + size.x
					and mouse_position.y >= global_position.y
					and mouse_position.y <= global_position.y + size.y
			):
				get_viewport().set_input_as_handled()
				dragged.emit()
