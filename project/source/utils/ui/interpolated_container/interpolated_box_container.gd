@tool
class_name InterpolatedBoxContainer
extends InterpolatedContainer
# This script was originally written by Gennaddy "Don Tnowe" Krupenyov.
# It has been modified.
# See LICENSE.md in same folder as this file.

## A container that displays children in a row or column,
## compacting them to fit width if too many,
## with a smooth repositioning feature.
##
## Handles children with the Expand size flag. [br]
## Control spacing by setting the theme's BoxContainer constants. [br]
## Provides optional drag-and-drop feature to reorder items via pointer. [br]
## [b]Note:[/b] users can only reorder/transfer children that have
## [member Control.mouse_filter] set to Stop. [br]
## [b]Note:[/b] this works with any [Control] type
## and does not require children to be [Draggable].

## Enable if the box should behave like a [VBoxContainer].
## Otherwise, works like an [HBoxContainer].
@export var vertical: bool = true:
	set(value):
		vertical = value
		queue_sort()

## Enable reordering by using the mouse pointer.
var _separation: float = 0.0


func _sort_children() -> void:
	_separation = get_theme_constant(&"separation", &"BoxContainer")

	var cur_child_minsize := Vector2.ZERO
	var cur_row_length: float = 0.0
	var widest_child: float = 0.0
	var cur_row_expand_count: int = 0
	for child in get_children(true):
		if child is not Control:
			continue
		var child_control := child as Control
		if not child_control.visible:
			continue

		cur_child_minsize = child_control.get_combined_minimum_size()
		if vertical:
			cur_row_length += cur_child_minsize.y + _separation
			widest_child = maxf(cur_child_minsize.x, widest_child)
			if child_control.size_flags_vertical & SIZE_EXPAND != 0:
				cur_row_expand_count += 1
		else:
			cur_row_length += cur_child_minsize.x + _separation
			widest_child = maxf(cur_child_minsize.y, widest_child)
			if child_control.size_flags_horizontal & SIZE_EXPAND != 0:
				cur_row_expand_count += 1

	cur_row_length -= _separation
	var result_size := (
			Vector2(size.x, cur_row_length) if vertical else
			Vector2(cur_row_length, size.y)
	)
	_fit_children_row(result_size, cur_row_expand_count)

	cached_minimum_size = (
			Vector2(widest_child, cur_row_length) if vertical else
			Vector2(cur_row_length, widest_child)
	)


func _fit_children_row(row_size: Vector2, expand_node_count: int) -> void:
	var cur_offset: float = 0.0
	if expand_node_count == 0:
		if vertical:
			if alignment == ItemAlignment.CENTER:
				cur_offset += (size.y - row_size.y) * 0.5
			if alignment == ItemAlignment.END:
				cur_offset += size.y - row_size.y
		else:
			if alignment == ItemAlignment.CENTER:
				cur_offset += (size.x - row_size.x) * 0.5
			if alignment == ItemAlignment.END:
				cur_offset += size.x - row_size.x

	# Keep track of the dragging node's position
	var _dragging_node_global_position := Vector2.ZERO
	if _dragging_node != null:
		_dragging_node_global_position = _dragging_node.global_position

	for child in get_children(true):
		if child is not Control:
			continue
		var child_control := child as Control
		if not child_control.visible:
			continue

		var cur_child_width: float = 0.0
		if vertical:
			cur_child_width = child_control.get_combined_minimum_size().y
			if (
					expand_node_count != 0
					and child_control.size_flags_vertical & SIZE_EXPAND != 0
			):
				cur_child_width += (size.y - row_size.y) / expand_node_count
		else:
			cur_child_width = child_control.get_combined_minimum_size().x
			if (
					expand_node_count != 0
					and child_control.size_flags_horizontal & SIZE_EXPAND != 0
			):
				cur_child_width += (size.x - row_size.x) / expand_node_count

		if vertical:
			fit_interpolated(child_control, Rect2(
					0.0, cur_offset, row_size.x, cur_child_width
			))
		else:
			fit_interpolated(child_control, Rect2(
					cur_offset, 0.0, cur_child_width, row_size.y
			))

		# Revert the dragging node's position to what it was
		if _dragging_node == child:
			_dragging_node.global_position = _dragging_node_global_position

		cur_offset += cur_child_width + _separation


func _insert_child_at_position(child: Control) -> void:
	var children: Array[Node] = get_children(true)
	var child_former_index: int = child.get_index()
	for i in children.size():
		if children[i] is not Control:
			continue
		var other_child := children[i] as Control
		if not other_child.visible:
			continue

		if (
				(vertical and other_child.position.y > child.position.y)
				or (not vertical and other_child.position.x > child.position.x)
		):
			var result_index: int = i if i < child_former_index else i - 1
			if result_index != child_former_index:
				move_child(child, result_index)
				order_changed.emit()

			return

	if child_former_index != children.size():
		move_child(child, children.size())
		order_changed.emit()
