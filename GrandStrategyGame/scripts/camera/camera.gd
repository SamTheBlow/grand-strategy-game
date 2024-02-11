class_name CustomCamera2D
extends Camera2D
## Please do not use Godot's built-in camera limits!
## This script uses custom code to implement it.


## How far away from the world the camera can go,
## measured in window size (e.g. 0.5 is half a window size).
## Negative numbers work, but are not recommended.
@export var world_margin: Vector2 = Vector2(0.5, 0.5)

var limits := WorldLimits.new()


func _ready() -> void:
	position = position_in_bounds(position)


## Takes a position and contains it within the camera's limits.
func position_in_bounds(input_position: Vector2) -> Vector2:
	# NOTE: all of this assumes the camera's anchor mode is Drag Center
	var margin_x: float = (
			(0.5 - world_margin.x) * get_viewport_rect().size.x / zoom.x
	)
	var margin_y: float = (
			(0.5 - world_margin.y) * get_viewport_rect().size.y / zoom.y
	)
	var min_x: float = limits.limit_left() + margin_x
	var min_y: float = limits.limit_top() + margin_y
	var max_x: float = limits.limit_right() - margin_x
	var max_y: float = limits.limit_bottom() - margin_y
	var output_x: float = clampf(input_position.x, min_x, max_x)
	var output_y: float = clampf(input_position.y, min_y, max_y)
	return Vector2(output_x, output_y)
