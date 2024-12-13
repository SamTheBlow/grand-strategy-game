class_name CameraDrag
extends Node
## Allows the player to freely drag the camera around using the mouse.
##
## NOTICE: for this to work as intended, the camera node must be setup in the
## scene tree such that it is in-between the world layer and the UI layer.

@export var camera: CustomCamera2D

var _is_being_dragged: bool = false


func _unhandled_input(event: InputEvent) -> void:
	_detect_start_of_drag(event)
	_detect_end_of_drag(event)


func _input(event: InputEvent) -> void:
	_drag_camera(event)


func _detect_start_of_drag(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	var event_mouse_button := event as InputEventMouseButton
	if not event_mouse_button.is_pressed():
		return

	if event_mouse_button.button_index != MOUSE_BUTTON_LEFT:
		return

	# You are now dragging the camera
	_is_being_dragged = true


func _detect_end_of_drag(event: InputEvent) -> void:
	if not event is InputEventMouseButton:
		return

	var event_mouse_button := event as InputEventMouseButton
	if not event_mouse_button.is_released():
		return

	if event_mouse_button.button_index != MOUSE_BUTTON_LEFT:
		return

	# You are no longer dragging the camera
	_is_being_dragged = false


func _drag_camera(event: InputEvent) -> void:
	if not _is_being_dragged or not event is InputEventMouseMotion:
		return
	var event_mouse_motion := event as InputEventMouseMotion

	# Move the camera
	var camera_position: Vector2 = camera.position_in_bounds(camera.position)
	var movement: Vector2 = -event_mouse_motion.relative / camera.zoom
	camera.position = camera.position_in_bounds(camera_position + movement)
