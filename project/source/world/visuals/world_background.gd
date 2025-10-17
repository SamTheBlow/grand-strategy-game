class_name WorldBackground
extends Node2D
## Emits a signal when clicked.
# In the future, you will be able to add a background image
# to a 2D world map, and maybe other things too.

signal clicked()


## Handles any left click event on the background
func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	var event_mouse_button := event as InputEventMouseButton

	if not event_mouse_button.button_index == MOUSE_BUTTON_LEFT:
		return

	get_viewport().set_input_as_handled()

	if not event_mouse_button.pressed:
		clicked.emit()
