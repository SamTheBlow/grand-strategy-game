class_name CustomCamera2D
extends Camera2D
## Clamps the camera's position and zoom according to given [WorldLimits].
##
## WARNING: If you set this node's "position" property directly,
## it will not automatically stay in bounds. Because of this,
## please use [method CustomCamera2D.move_to] to move the camera.

signal zoom_limits_changed(minimum_zoom: float, maximum_zoom: float)

## How far away from the world the camera can go,
## measured in window size (e.g. 0.5 is half a window size).
@export var world_margin := Vector2(0.5, 0.5)

## May be null, in which case there are no bounds.
var world_limits: WorldLimits = null:
	set(value):
		if world_limits != null:
			world_limits.current_limits_changed.disconnect(_refresh)

		world_limits = value
		_refresh()

		if world_limits != null:
			world_limits.current_limits_changed.connect(_refresh.unbind(1))


func _ready() -> void:
	_refresh()
	get_viewport().size_changed.connect(_refresh)


func _refresh() -> void:
	_reposition_in_bounds()

	var minimum_zoom: float = _minimum_zoom()
	var maximum_zoom: float = _maximum_zoom()
	set_zoom_clamped(zoom.x, minimum_zoom, maximum_zoom)
	zoom_limits_changed.emit(minimum_zoom, maximum_zoom)


## Returns the given position contained within the world limits.
## The camera must be in the scene tree for this function to work.
func position_in_bounds(input_position: Vector2) -> Vector2:
	if not is_inside_tree():
		push_error(
				"Tried to get an in-bounds position, "
				+ "but the camera is not in the scene tree."
		)
		return input_position

	if world_limits == null:
		return input_position

	# NOTE: all of this assumes the camera's anchor mode is Drag Center
	var margin_x: float = (
			(0.5 - world_margin.x) * get_viewport_rect().size.x / zoom.x
	)
	var margin_y: float = (
			(0.5 - world_margin.y) * get_viewport_rect().size.y / zoom.y
	)
	var min_x: float = world_limits.limit_left() + margin_x
	var min_y: float = world_limits.limit_top() + margin_y
	var max_x: float = world_limits.limit_right() - margin_x
	var max_y: float = world_limits.limit_bottom() - margin_y

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


func move_to_world_center() -> void:
	move_to(world_limits.center())


## Translates this node by the given offset in local coordinates.
func translate_not_zoomed(position_offset: Vector2) -> void:
	position += position_offset
	_reposition_in_bounds()


## Translates this node by the given offset in local coordinates,
## with the camera's zoom taken into account.
func translate_zoomed(position_offset: Vector2) -> void:
	position += position_offset / zoom
	_reposition_in_bounds()


func set_zoom_clamped(
		zoom_value: float,
		minimum_zoom: float = _minimum_zoom(),
		maximum_zoom: float = _maximum_zoom()
) -> void:
	zoom = Vector2.ONE * clampf(zoom_value, minimum_zoom, maximum_zoom)


## Ensures the camera stays in bounds.
## No effect if the camera is not in the scene tree.
func _reposition_in_bounds() -> void:
	if not is_inside_tree():
		return
	position = position_in_bounds(position)


## Currently, you can zoom out such that the world takes half the screen.
func _minimum_zoom() -> float:
	if not is_inside_tree() or world_limits == null:
		return -INF

	# Prevent division by zero
	if (
			world_limits.width() == 0.0
			or world_limits.height() == 0.0
	):
		return -INF

	return 0.5 * minf(
			get_viewport_rect().size.x / world_limits.width(),
			get_viewport_rect().size.y / world_limits.height()
	)


## Currently, you can zoom in no further than some arbitrary value.
func _maximum_zoom() -> float:
	const MAXIMUM_ZOOM: float = 1.0
	return maxf(MAXIMUM_ZOOM, _minimum_zoom())
