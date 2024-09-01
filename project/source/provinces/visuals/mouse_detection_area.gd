extends Area2D
## Provides extra signals for mouse detection.


## Emitted when a mouse event occurs and the mouse cursor is inside this area.
## This one is only emitted when the event is unhandled.
signal unhandled_mouse_event_occured(event: InputEventMouse)
## Emitted when a mouse event occurs and the mouse cursor is inside this area.
signal mouse_event_occured(event: InputEventMouse)

var _mouse_is_inside_shape: bool = false


func _ready() -> void:
	mouse_entered.connect(func() -> void: _mouse_is_inside_shape = true)
	mouse_exited.connect(func() -> void: _mouse_is_inside_shape = false)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouse and _mouse_is_inside_shape:
		unhandled_mouse_event_occured.emit(event as InputEventMouse)


func _input(event: InputEvent) -> void:
	if event is InputEventMouse and _mouse_is_inside_shape:
		mouse_event_occured.emit(event as InputEventMouse)


#func mouse_is_inside_shape() -> bool:
	#var mouse_position_in_world: Vector2 = (
			#PositionScreenToWorld.new()
			#.result(get_viewport().get_mouse_position(), get_viewport())
	#)
	#var local_mouse_position: Vector2 = (
			#mouse_position_in_world - global_position
	#)
	#return Geometry2D.is_point_in_polygon(local_mouse_position, polygon)
