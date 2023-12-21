class_name CameraDrag
extends Node
## Allows the player to freely drag the camera around using the mouse.
##
## This node is meant to be added as a child of a Camera2D node.
## 
## IMPORTANT: for this node to work as intended, the camera node
## must be setup such that it is inbetween the UI layer and the world layer.


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
	
	var camera := get_parent() as Camera2D
	if not camera:
		return
	
	# Move the camera
	camera.position -= event_mouse_motion.relative / camera.zoom
	
	# Keep the camera in bounds
	# (All of this assumes the camera's anchor mode is Fixed TopLeft)
	var viewport_rect_size: Vector2 = camera.get_viewport_rect().size
	var max_x: float = (
			camera.limit_right - viewport_rect_size.x / camera.zoom.x
	)
	var max_y: float = (
			camera.limit_bottom - viewport_rect_size.y / camera.zoom.y
	)
	camera.position.x = clampf(camera.position.x, 0.0, max_x)
	camera.position.y = clampf(camera.position.y, 0.0, max_y)
