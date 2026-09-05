class_name WindowModeInput
extends Node
## Toggles between windowed and fullscreen when its action is pressed.

## The input action's name in the project settings.
@export var action_name: StringName


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(action_name):
		toggle_fullscreen()
		get_viewport().set_input_as_handled()


func toggle_fullscreen() -> void:
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
