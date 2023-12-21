class_name CustomCamera2D
extends Camera2D


func _ready() -> void:
	keep_in_bounds()


## Keeps the camera's position in bounds.
## Meant to be used whenever the camera's position is manually changed.
func keep_in_bounds() -> void:
	# NOTE: all of this assumes the camera's anchor mode is Drag Center
	var min_x: float = limit_left + get_viewport_rect().size.x * 0.5 / zoom.x
	var min_y: float = limit_top + get_viewport_rect().size.y * 0.5 / zoom.y
	var max_x: float = limit_right - get_viewport_rect().size.x * 0.5 / zoom.x
	var max_y: float = limit_bottom - get_viewport_rect().size.y * 0.5 / zoom.y
	position.x = clampf(position.x, min_x, max_x)
	position.y = clampf(position.y, min_y, max_y)
