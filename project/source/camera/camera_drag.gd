class_name CameraDrag
extends Node
## Allows the player to freely drag the camera around using the mouse.
##
## NOTICE: for this to work as intended, the camera node must be setup in the
## scene tree such that it is in-between the world layer and the UI layer.

signal drag_started()
signal drag_ended()

@export var _camera: CustomCamera2D

var _is_being_dragged: bool = false


func _unhandled_input(event: InputEvent) -> void:
	_detect_start_of_drag(event)
	_detect_end_of_drag(event)


func _input(event: InputEvent) -> void:
	_drag_camera(event)


func _detect_start_of_drag(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	var event_mouse_button := event as InputEventMouseButton
	if not (
			event_mouse_button.is_pressed()
			and event_mouse_button.button_index == MOUSE_BUTTON_LEFT
	):
		return

	# You are now dragging the camera
	_is_being_dragged = true
	drag_started.emit()


func _detect_end_of_drag(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return

	var event_mouse_button := event as InputEventMouseButton
	if not (
			event_mouse_button.is_released()
			and event_mouse_button.button_index == MOUSE_BUTTON_LEFT
	):
		return

	# You are no longer dragging the camera
	_is_being_dragged = false
	drag_ended.emit()


func _drag_camera(event: InputEvent) -> void:
	if not _is_being_dragged or event is not InputEventMouseMotion:
		return
	var event_mouse_motion := event as InputEventMouseMotion

	_camera.move_to(
			_camera.position - event_mouse_motion.relative / _camera.zoom
	)
