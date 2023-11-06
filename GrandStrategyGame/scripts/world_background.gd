class_name WorldBackground
extends Node2D


signal clicked()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var event_typed := event as InputEventMouseButton
		if (
				event_typed.pressed
				and not event_typed.is_echo()
				and event_typed.button_index == MOUSE_BUTTON_LEFT
		):
			get_viewport().set_input_as_handled()
			clicked.emit()
