class_name CustomCamera2D
extends Camera2D


func _ready() -> void:
	position = position_in_bounds(position)


## Takes a position and contains it within the camera's limits.
func position_in_bounds(input_position: Vector2) -> Vector2:
	# NOTE: all of this assumes the camera's anchor mode is Drag Center
	var min_x: float = limit_left + get_viewport_rect().size.x * 0.5 / zoom.x
	var min_y: float = limit_top + get_viewport_rect().size.y * 0.5 / zoom.y
	var max_x: float = limit_right - get_viewport_rect().size.x * 0.5 / zoom.x
	var max_y: float = limit_bottom - get_viewport_rect().size.y * 0.5 / zoom.y
	var output_x: float = clampf(input_position.x, min_x, max_x)
	var output_y: float = clampf(input_position.y, min_y, max_y)
	return Vector2(output_x, output_y)
