class_name CustomCamera2D
extends Camera2D
## Clamps the camera's position according to given limits.
##
## WARNING: If you set this node's "position" property directly,
## it will not automatically stay in bounds. Because of this,
## please use [method CustomCamera2D.move_to] to move the camera.

## How far away from the world the camera can go,
## measured in window size (e.g. 0.5 is half a window size).
@export var world_margin := Vector2(0.5, 0.5)

## The active world bounds. Unlimited until a world is loaded.
var _left: float = -INF
var _top: float = -INF
var _right: float = INF
var _bottom: float = INF


func _ready() -> void:
	# Keep the camera in bounds if the viewport is resized.
	get_viewport().size_changed.connect(_reposition_in_bounds)


func set_limits(left: float, top: float, right: float, bottom: float) -> void:
	_left = left
	_top = top
	_right = right
	_bottom = bottom
	_reposition_in_bounds()


func zoom_to(new_zoom: Vector2) -> void:
	zoom = new_zoom
	_reposition_in_bounds()


## Returns the given position contained within the world limits.
## The camera must be in the scene tree for this function to work.
func position_in_bounds(input_position: Vector2) -> Vector2:
	if not is_inside_tree():
		push_error(
				"Tried to get an in-bounds position, "
				+ "but the camera is not in the scene tree."
		)
		return input_position

	# NOTE: all of this assumes the camera's anchor mode is Drag Center
	var margin_x: float = (
			(0.5 - world_margin.x) * get_viewport_rect().size.x / zoom.x
	)
	var margin_y: float = (
			(0.5 - world_margin.y) * get_viewport_rect().size.y / zoom.y
	)
	var min_x: float = _left + margin_x
	var min_y: float = _top + margin_y
	var max_x: float = _right - margin_x
	var max_y: float = _bottom - margin_y

	var output: Vector2
	if min_x < max_x:
		output.x = clampf(input_position.x, min_x, max_x)
	else:
		output.x = (min_x + max_x) * 0.5
	if min_y < max_y:
		output.y = clampf(input_position.y, min_y, max_y)
	else:
		output.y = (min_y + max_y) * 0.5

	return output


func move_to(new_position: Vector2) -> void:
	position = new_position
	_reposition_in_bounds()


## Translates this node by the given offset in local coordinates.
func translate_not_zoomed(position_offset: Vector2) -> void:
	position += position_offset
	_reposition_in_bounds()


## Translates this node by the given offset in local coordinates,
## with the camera's zoom taken into account.
func translate_zoomed(position_offset: Vector2) -> void:
	position += position_offset / zoom
	_reposition_in_bounds()


## Ensures the camera stays in bounds.
## No effect if the camera is not in the scene tree.
func _reposition_in_bounds() -> void:
	if not is_inside_tree():
		return
	position = position_in_bounds(position)
