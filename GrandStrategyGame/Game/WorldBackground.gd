extends Node2D

signal clicked

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and not event.is_echo() and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		emit_signal("clicked")
