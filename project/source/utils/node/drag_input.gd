class_name DragInput
extends Node
## Provides signals for dragging something with the mouse.

signal drag_started()
signal drag_moved(delta: Vector2)
signal drag_ended()

## Does not start new drags when disabled.
@export var is_enabled: bool = true:
	set = set_is_enabled

## If true, marks inputs as handled.
@export var eat_input: bool = false

## If true, delta is scaled by camera zoom.
@export var apply_camera_zoom: bool = false

## If true, delta moves away from the mouse. (useful for e.g. camera)
@export var inverse_delta: bool = false

var _is_being_dragged: bool = false
var _has_moved: bool = false


func _input(event: InputEvent) -> void:
	if not _is_being_dragged:
		return
	_handle_drag_move(event)
	_handle_drag_end(event)


func _unhandled_input(event: InputEvent) -> void:
	if not is_enabled:
		return
	_handle_drag_start(event)


func _handle_drag_start(event: InputEvent) -> void:
	var event_mouse_button := event as InputEventMouseButton
	if (
			event_mouse_button == null
			or event_mouse_button.button_index != MOUSE_BUTTON_LEFT
			or not event_mouse_button.is_pressed()
	):
		return

	_is_being_dragged = true
	_has_moved = false
	drag_started.emit()
	if eat_input:
		get_viewport().set_input_as_handled()


func _handle_drag_end(event: InputEvent) -> void:
	var event_mouse_button := event as InputEventMouseButton
	if (
			event_mouse_button == null
			or event_mouse_button.button_index != MOUSE_BUTTON_LEFT
			or event_mouse_button.is_pressed()
	):
		return

	_is_being_dragged = false
	drag_ended.emit()
	if eat_input and _has_moved:
		get_viewport().set_input_as_handled()


func _handle_drag_move(event: InputEvent) -> void:
	var event_mouse_motion := event as InputEventMouseMotion
	if event_mouse_motion == null:
		return

	var delta: Vector2 = event_mouse_motion.relative
	if inverse_delta:
		delta *= -1
	if apply_camera_zoom:
		delta /= get_viewport().get_camera_2d().zoom
	drag_moved.emit(delta)

	_has_moved = true

	if eat_input:
		get_viewport().set_input_as_handled()


func set_is_enabled(value: bool) -> void:
	is_enabled = value
