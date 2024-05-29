class_name WorldBackground
extends Node2D
## The background for a [GameWorld2D].
## Currently has no effect, but in the future, you will be able to 
## add a background image to a 2D world map, and maybe other effects too.


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
