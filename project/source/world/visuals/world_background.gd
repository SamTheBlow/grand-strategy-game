class_name WorldBackground
extends Node2D
## Sets all left click input events as handled
## and emits a signal when left clicked.

signal clicked()


func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	var event_mouse_button := event as InputEventMouseButton

	if event_mouse_button.button_index != MOUSE_BUTTON_LEFT:
		return

	get_viewport().set_input_as_handled()

	if not event_mouse_button.pressed:
		clicked.emit()
