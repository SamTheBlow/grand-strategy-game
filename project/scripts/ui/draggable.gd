class_name Draggable
extends Control
## Attach this script to any Control node you would like
## the user to be able to drag around with their mouse.
##
## To use, you need to have a node that emits a signal when clicked on,
## and you need to connect that signal to [method Draggable._on_dragged].
## You only need to check for when the mouse button is first pressed:
## this node will take care of checking if the button is held or released.


var _is_being_dragged: bool = false
var _relative_starting_position := Vector2.ZERO
var _relative_mouse_origin := Vector2.ZERO


func _process(_delta: float) -> void:
	if _is_being_dragged:
		var relative_position: Vector2 = _relative_mouse_position()
		var delta_x: float = relative_position.x - _relative_mouse_origin.x
		var delta_y: float = relative_position.y - _relative_mouse_origin.y
		var relative_width: float = anchor_right - anchor_left
		var relative_height: float = anchor_bottom - anchor_top
		anchor_left = _relative_starting_position.x + delta_x
		anchor_left = clampf(anchor_left, 0, 1 - relative_width)
		anchor_right = anchor_left + relative_width
		anchor_top = _relative_starting_position.y + delta_y
		anchor_top = clampf(anchor_top, 0, 1 - relative_height)
		anchor_bottom = anchor_top + relative_height


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var event_typed := event as InputEventMouseMotion
		if (
				_is_being_dragged
				and event_typed.button_mask == MOUSE_BUTTON_MASK_LEFT
		):
			get_viewport().set_input_as_handled()
	elif event is InputEventMouseButton:
		var event_typed := event as InputEventMouseButton
		if (
				not event_typed.pressed
				and event_typed.button_index == MOUSE_BUTTON_LEFT
		):
			_is_being_dragged = false


## Returns the mouse position in the window as values from 0 to 1,
## where 0 is the top/left and 1 is the bottom/right.
func _relative_mouse_position() -> Vector2:
	var mouse_position: Vector2 = get_viewport().get_mouse_position()
	var window_size: Vector2 = get_viewport().get_visible_rect().size
	return Vector2(
			mouse_position.x / window_size.x,
			mouse_position.y / window_size.y
	)


## Only works for objects anchored to the top-left corner.
## Currently unused and WIP.
func _clamp_to(control: Control) -> void:
	var delta_x: float = anchor_left - control.anchor_right
	var delta_y: float = anchor_top - control.anchor_bottom
	if delta_x < 0 and delta_y < 0:
		if delta_x < delta_y:
			var relative_height: float = anchor_bottom - anchor_top
			anchor_top = control.anchor_bottom
			anchor_bottom = anchor_top + relative_height
		else:
			var relative_width: float = anchor_right - anchor_left
			anchor_left = control.anchor_right
			anchor_right = anchor_left + relative_width


## Connect signals to this
func _on_dragged() -> void:
	_is_being_dragged = true
	_relative_starting_position = Vector2(anchor_left, anchor_top)
	_relative_mouse_origin = _relative_mouse_position()
