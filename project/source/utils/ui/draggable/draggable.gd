@tool
class_name Draggable
extends Container
## Draggable control. Can be resized by dragging the border,
## and constrained to only be movable within its parent Control.
##
## [b]Note:[/b] this container will only be grabbed if the mouse pointer does
## not overlap children with [member Control.mouse_filter] set to Stop. [br]
## [b]Note:[/b] this can be the child of any [Control],
## but it is not compatible with [InterpolatedContainer].
# This is a modified version of code originally written by
# Gennaddy "Don Tnowe" Krupenyov.
# The license can be found in the same folder as this file.
# See the original code here:
# https://github.com/don-tnowe/godot-extra-controls

## Emitted when the mouse button is released after the node is moved or resized.
signal drag_ended()

## Enable so the node can be dragged and resized horizontally (X axis)
@export var can_drag_horizontal: bool = true
## Enable so the node can be dragged and resized vertically (Y axis)
@export var can_drag_vertical: bool = true
## Size of the grid to align the node with when the node is moved or resized.
@export var grid_snap := Vector2.ZERO
## Width of the resize border. If the mouse pointer is on this border,
## the node will be resized, otherwise it will be moved.
## [br] Set to 0 on either axis to prevent resizing on that axis.
@export var resize_margin := Vector2.ZERO:
	set(value):
		resize_margin = value
		queue_redraw()
		queue_sort()
## Color of the rectangle indicating the node's drop position
## and the selected side of the [member resize_margin].
@export var drop_color := Color(0.5, 0.5, 0.5, 0.75)
## Defines if this node's children are shrunk
## by the [member resize_margin]'s size.
@export var resize_margin_offset_children: bool = true:
	set(value):
		resize_margin_offset_children = value
		queue_redraw()
		queue_sort()
## Defines if this node can only be resized to multiples of [member grid_snap].
@export var grid_snap_affects_resize: bool = true
## Defines if this node can not be dragged or resized
## beyond the parent control's bounds.
@export var constrain_rect_to_parent: bool = true

@export var draw_resize_margins: bool = true:
	set(value):
		draw_resize_margins = value
		queue_redraw()

var _mouse_over: bool = false
var _mouse_dragging: bool = false
var _mouse_dragging_direction := Vector2i.ZERO
var _drag_initial_pos := Vector2.ZERO
var _size_buffered := Vector2.ZERO


func _init() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _draw() -> void:
	if _mouse_dragging:
		var result_rect: Rect2 = get_rect_after_drop()
		result_rect.position -= position
		draw_rect(result_rect, drop_color)
	elif _mouse_over:
		if (
				not draw_resize_margins
				or _mouse_dragging_direction == Vector2i.ZERO
		):
			draw_rect(Rect2(Vector2.ZERO, size), drop_color)
			return

		var result_rect := Rect2(Vector2.ZERO, resize_margin)
		if _mouse_dragging_direction.x == 1:
			result_rect.position.x = size.x - resize_margin.x
		if _mouse_dragging_direction.y == 0:
			result_rect.size.y = size.y
		if _mouse_dragging_direction.y == 1:
			result_rect.position.y = size.y - resize_margin.y
		if _mouse_dragging_direction.x == 0:
			result_rect.size.x = size.x
		draw_rect(result_rect, drop_color)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var event_mouse_motion := event as InputEventMouseMotion

		if _mouse_dragging:
			_universal_input(
					_mouse_dragging_direction, event_mouse_motion.relative
			)
		elif resize_margin == Vector2.ZERO:
			_mouse_dragging_direction = Vector2i.ZERO
			mouse_default_cursor_shape = CURSOR_ARROW
		else:
			var new_dragging_direction: Vector2i

			if event_mouse_motion.position.x < resize_margin.x:
				new_dragging_direction.x = -1
			elif event_mouse_motion.position.x > size.x - resize_margin.x:
				new_dragging_direction.x = 1
			else:
				new_dragging_direction.x = 0

			if event_mouse_motion.position.y < resize_margin.y:
				new_dragging_direction.y = -1
			elif event_mouse_motion.position.y > size.y - resize_margin.y:
				new_dragging_direction.y = 1
			else:
				new_dragging_direction.y = 0

			match 3 * new_dragging_direction.y + new_dragging_direction.x:
				-4: mouse_default_cursor_shape = CURSOR_FDIAGSIZE
				-3: mouse_default_cursor_shape = CURSOR_VSIZE
				-2: mouse_default_cursor_shape = CURSOR_BDIAGSIZE
				-1: mouse_default_cursor_shape = CURSOR_HSIZE
				0:  mouse_default_cursor_shape = CURSOR_ARROW
				+1: mouse_default_cursor_shape = CURSOR_HSIZE
				+2: mouse_default_cursor_shape = CURSOR_BDIAGSIZE
				+3: mouse_default_cursor_shape = CURSOR_VSIZE
				+4: mouse_default_cursor_shape = CURSOR_FDIAGSIZE

			Input.set_default_cursor_shape(Input.CursorShape.CURSOR_ARROW)
			if new_dragging_direction != _mouse_dragging_direction:
				_mouse_dragging_direction = new_dragging_direction
				queue_redraw()
	elif event is InputEventMouseButton:
		var event_mouse_button := event as InputEventMouseButton
		if event_mouse_button.button_index == MOUSE_BUTTON_LEFT:
			_handle_click(event_mouse_button.pressed)


func _get_minimum_size() -> Vector2:
	return _get_resize_minimum_size()


func _notification(what: int) -> void:
	if what != NOTIFICATION_SORT_CHILDREN:
		return

	var result_child_pos := Vector2.ZERO
	if resize_margin_offset_children:
		result_child_pos = resize_margin

	for child_node in get_children(true):
		if child_node is not Control:
			continue
		var child_control := child_node as Control
		child_control.position = result_child_pos
		child_control.size = size - result_child_pos * 2.0


func get_rect_after_drop() -> Rect2:
	var grid_snap_offset_cur: Vector2 = grid_snap * 0.5 - Vector2.ONE
	var result_position: Vector2 = position
	var result_size: Vector2 = size

	if grid_snap != Vector2.ZERO:
		if _mouse_dragging_direction != Vector2i.ZERO:
			result_position = (
					(result_position - grid_snap * 0.5).snapped(grid_snap)
			)
		else:
			result_position = result_position.snapped(grid_snap)

		if grid_snap_affects_resize:
			result_size = (size + grid_snap_offset_cur).snapped(grid_snap)

	var xform_basis: Transform2D = get_transform().translated(-position)
	var xformed_rect: Rect2 = (xform_basis * Rect2(Vector2.ZERO, result_size))
	var xformed_position: Vector2 = xformed_rect.position + result_position
	var xformed_size: Vector2 = xformed_rect.size

	if constrain_rect_to_parent:
		var parent: Node = get_parent()
		if parent is Control:
			var parent_size: Vector2 = (parent as Control).size

			if size.x > parent_size.x:
				if _mouse_dragging_direction.x < 0:
					result_position.x = 0.0
				result_size.x = parent_size.x

			if size.y > parent_size.y:
				if _mouse_dragging_direction.y < 0:
					result_position.y = 0.0
				result_size.y = parent_size.y

			if xformed_position.x < 0.0:
				result_position -= (
						xform_basis.affine_inverse()
						* Vector2(xformed_position.x, 0.0)
				)

			if xformed_position.y < 0.0:
				result_position -= (
						xform_basis.affine_inverse()
						* Vector2(0.0, xformed_position.y)
				)

			if xformed_position.x > parent_size.x - xformed_size.x:
				result_position -= (
						xform_basis.affine_inverse()
						* Vector2(
								xformed_position.x
								- (parent_size.x - xformed_size.x),
								0.0
						)
				)

			if xformed_position.y > parent_size.y - xformed_size.y:
				result_position -= (
						xform_basis.affine_inverse()
						* Vector2(
								0.0,
								xformed_position.y
								- (parent_size.y - xformed_size.y)
						)
				)

	if not can_drag_horizontal:
		result_position.x = _drag_initial_pos.x
	if not can_drag_vertical:
		result_position.y = _drag_initial_pos.y

	return Rect2(result_position, result_size)


func _get_resize_minimum_size() -> Vector2:
	var result_size := Vector2.ZERO
	for child_node in get_children(true):
		if child_node is not Control:
			continue
		var minsize: Vector2 = (
				(child_node as Control).get_combined_minimum_size()
		)
		result_size.x = maxf(result_size.x, minsize.x)
		result_size.y = maxf(result_size.y, minsize.y)

	if resize_margin_offset_children:
		result_size += resize_margin + resize_margin

	return Vector2(
			maxf(result_size.x, custom_minimum_size.x),
			maxf(result_size.y, custom_minimum_size.y),
	)


func _universal_input(
		input_resize_direction: Vector2i, drag_amount: Vector2
) -> void:
	if input_resize_direction == Vector2i.ZERO:
		position += get_transform().basis_xform(drag_amount)
		queue_redraw()
		return

	if input_resize_direction.x != 0:
		_size_buffered.x += drag_amount.x * input_resize_direction.x
	if input_resize_direction.y != 0:
		_size_buffered.y += drag_amount.y * input_resize_direction.y

	var is_diagonal: bool = (
			absi(input_resize_direction.x)
			+ absi(input_resize_direction.y) == 2
	)
	var pos_change := Vector2.ZERO
	var minsize: Vector2 = _get_resize_minimum_size()

	if (
			(is_diagonal or input_resize_direction.x == 0)
			and input_resize_direction.y <= 0
			and _size_buffered.y >= minsize.y
	):
		pos_change.y = drag_amount.y

	if (
			(is_diagonal or input_resize_direction.y == 0)
			and input_resize_direction.x <= 0
			and _size_buffered.x >= minsize.x
	):
		pos_change.x = drag_amount.x

	position += get_transform().basis_xform(pos_change)
	size = _size_buffered
	queue_redraw()


func _handle_click(button_pressed: bool) -> void:
	_mouse_dragging = button_pressed

	if not _mouse_dragging:
		var result_rect: Rect2 = get_rect_after_drop()
		position = result_rect.position
		size = result_rect.size
		drag_ended.emit()

	_size_buffered = size
	_drag_initial_pos = position
	queue_redraw()


func _on_mouse_entered() -> void:
	_mouse_over = true
	queue_redraw()


func _on_mouse_exited() -> void:
	_mouse_over = false
	queue_redraw()
