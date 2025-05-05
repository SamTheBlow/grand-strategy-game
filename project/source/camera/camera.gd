class_name CustomCamera2D
extends Camera2D
## Keeps the camera's position inside given world limits.[br]
## [br]
## WARNING: Please do not use Godot's built-in camera limits!
## This script uses custom code for camera limits.[br]
## [br]
## WARNING: If you set this node's "position" property directly,
## it will not automatically stay in bounds. Because of this,
## please use [method CustomCamera2D.move_to] to move the camera.

## How far away from the world the camera can go,
## measured in window size (e.g. 0.5 is half a window size).
@export var world_margin := Vector2(0.5, 0.5)

var world_limits := WorldLimits.new():
	set(value):
		propagate_call(&"_disconnect_world_limits", [world_limits])
		world_limits = value
		_reposition_in_bounds()
		propagate_call(&"_connect_world_limits", [world_limits])


func _ready() -> void:
	_reposition_in_bounds()


func move_to(new_position: Vector2) -> void:
	position = new_position
	_reposition_in_bounds()


func move_to_world_center() -> void:
	move_to(world_limits.center())


## Returns the given position contained within the camera limits.
## The camera must be in the scene tree for this function to work.
func position_in_bounds(input_position: Vector2) -> Vector2:
	if not is_inside_tree():
		push_error(
				"Tried to get an in-bounds position, "
				+ "but the camera is not in the scene tree."
		)
		return Vector2.ZERO

	# NOTE: all of this assumes the camera's anchor mode is Drag Center
	var margin_x: float = (
			(0.5 - world_margin.x) * get_viewport_rect().size.x / zoom.x
	)
	var margin_y: float = (
			(0.5 - world_margin.y) * get_viewport_rect().size.y / zoom.y
	)
	var min_x: float = world_limits.limit_left + margin_x
	var min_y: float = world_limits.limit_top + margin_y
	var max_x: float = world_limits.limit_right - margin_x
	var max_y: float = world_limits.limit_bottom - margin_y
	var output_x: float = clampf(input_position.x, min_x, max_x)
	var output_y: float = clampf(input_position.y, min_y, max_y)
	return Vector2(output_x, output_y)


## Puts the camera back in bounds.
## Has no effect if the camera is not in the scene tree.
func _reposition_in_bounds() -> void:
	if not is_inside_tree():
		return

	position = position_in_bounds(position)


func _connect_world_limits(_world_limits: WorldLimits) -> void:
	if world_limits == null:
		push_error("World limits is null.")
		return

	if not world_limits.changed.is_connected(_on_world_limits_changed):
		world_limits.changed.connect(_on_world_limits_changed)


func _disconnect_world_limits(_world_limits: WorldLimits) -> void:
	if world_limits == null:
		push_error("World limits is null.")
		return

	if world_limits.changed.is_connected(_on_world_limits_changed):
		world_limits.changed.disconnect(_on_world_limits_changed)


func _on_world_limits_changed(_world_limits: WorldLimits) -> void:
	_reposition_in_bounds()
