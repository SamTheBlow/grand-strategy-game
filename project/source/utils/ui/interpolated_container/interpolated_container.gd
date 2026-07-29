@tool
class_name InterpolatedContainer
extends Container
# This script was originally written by Gennaddy "Don Tnowe" Krupenyov.
# It has been modified.
# See LICENSE.md in same folder as this file.

## Base class for containers that, when children inserted,
## animate their movement toward their target position.
##
## Provides optional drag-and-drop feature to reorder items via pointer. [br]
## [b]Note:[/b] users can only reorder/transfer
## children that have [member Control.mouse_filter] set to Stop. [br]
## [b]Note:[/b] this works with any [Control] type
## and does not require children to be [Draggable].

## Emitted when a node was dragged to be rearranged
## via [member allow_drag_reorder], every time the child order changes.
@warning_ignore("unused_signal")
signal order_changed()
## Emitted if [member allow_drag_reorder] enabled,
## when a node was grabbed to be rearranged, once.
signal drag_started(node: Control)
## Emitted if [member allow_drag_reorder] enabled,
## when a node was placed down after dragging, once. [br]
## [b]Note:[/b] if transfered into another container,
## will be emitted by that container.
signal drag_ended(node: Control)
## Emitted if [member allow_drag_reorder] enabled,
## every time a node is moved by the mouse while being dragged.
signal drag_moved(node: Control)
## Emitted if [member allow_drag_transfer] enabled,
## once a node is transfered to another container by being dragged.
signal drag_transfered_out(node: Control, into: InterpolatedContainer)
## Emitted if [member allow_drag_insert] enabled,
## once a node is transfered out of another container by being dragged.
signal drag_transfered_in(node: Control, from: InterpolatedContainer)

## Child alignment enum.
enum ItemAlignment {
	BEGIN,
	CENTER,
	END,
}

## Alignment of the items in the container,
## when behaviours such as Expand Sizing and Compaction are not active.
@export var alignment: ItemAlignment:
	set(value):
		alignment = value
		queue_sort()

## Time it takes for children to move into position.
@export var move_time: float = 0.5
## Easing factor to interpolate children to their target position.
## 1 is linear, [0, 1] is Ease Out,
## 1 and higher is Ease In, below -1 is Ease In-Out.
@export var easing_factor: float = 0.5

@export_group("Drag and Drop")
@export var allow_drag_reorder: bool = true
## Enable dragging children to be placed in other InterpolatedBoxContainers,
## by using the mouse pointer.
@export var allow_drag_transfer: bool = false
## Enable nodes to be placed here from other InterpolatedBoxContainers,
## by using the mouse pointer.
@export var allow_drag_insert: bool = false:
	set(value):
		allow_drag_insert = value
		if is_inside_tree():
			if value:
				_all_boxes.append(self)
			else:
				_all_boxes.erase(self)

## If the child count matches this,
## new children cannot be added through [member allow_drag_insert].
## Does not prevent other means of adding children.[br]
## Set to [code]-1[/code] to remove the limit. [br]
## This is equivalent to [member drag_insert_condition] set to
## [code]into.get_child_count() < (count)[/code].
@export var drag_max_count: int = -1:
	set(value):
		if value < -1:
			value = -1
		drag_max_count = value

## Expression to test for [member allow_drag_insert]
## to know if a node can be inserted, executed on the node.
## If [code]true[/code], the node will be inserted.[br]
## The [code]from[/code] parameter will be a reference to the node
## it's dragged from, and [code]into[/code] will be this node. [br][br]
## For example, expression [code](get_class() == "Button"
## and into.has_method(&"insert_button_node"))[/code]
## tests if the dragged node is [code]Button[/code]
## and the destination has method[code]insert_button_node[/code]. [br][br]
## [b]Warning: [/b] Some operators are unsupported in expressions,
## such as [code]is[/code] and ternary [code]if[/code]. Consider
## calling node's script methods after checking [code]has_method[/code].
@export var drag_insert_condition: String = "":
	set(value):
		drag_insert_condition = value
		if value.is_empty():
			_drag_insert_condition_exp = null
		else:
			_drag_insert_condition_exp = Expression.new()
			_drag_insert_condition_exp.parse(value, ["from", "into"])

## Expression to execute on the node after insertion succeeds.
## Same parameters as [member drag_insert_condition].
@export var drag_insert_call_on_success: String = ""

## Stores this node's minimum size, calculated from child positions.
## Must be set from [method _sort_children].
var cached_minimum_size := Vector2()

static var _all_boxes: Array[InterpolatedContainer] = []

var _drag_insert_condition_exp: Expression
var _dragging_node: Control
var _children_xforms_start: Array[Transform2D] = []
var _children_xforms_end: Array[Transform2D] = []
var _children_sizes_start: Array[Vector2] = []
var _children_sizes_end: Array[Vector2] = []
var _interp_progress_factor: float = 0.0
var _skip_next_reorder: bool = false

## Tracks children that were just added to the tree.
## Used to skip animation for their initial placement,
## preventing them from animating from their default layout rect
## (often the container's full rect) to their target position.
var _new_children: Array[Control] = []

## If non-null, it means this node's parent is this [ScrollContainer].
var _parent_scroll: ScrollContainer = null
var _scroll_horizontal_before: int = 0
var _scroll_vertical_before: int = 0


func _ready() -> void:
	set_process_input(false)
	child_entered_tree.connect(_on_child_entered_tree)
	child_exiting_tree.connect(_on_child_exiting_tree)
	for child_node in get_children(true):
		_on_child_entered_tree(child_node)

	var parent: Node = get_parent()
	if parent != null and parent is ScrollContainer:
		_parent_scroll = parent as ScrollContainer
		_scroll_horizontal_before = _parent_scroll.scroll_horizontal
		_scroll_vertical_before = _parent_scroll.scroll_vertical


func _enter_tree() -> void:
	if allow_drag_insert:
		_all_boxes.append(self)


func _exit_tree() -> void:
	_all_boxes.erase(self)


func _process(delta: float) -> void:
	if move_time == 0.0:
		set_process(false)
		return

	_skip_next_reorder = false
	_interp_progress_factor += 1.0 / move_time * delta
	var progress_eased: float = ease(_interp_progress_factor, easing_factor)
	var children: Array[Node] = get_children(true)
	var dragged_node_pos: Vector2 = (
			_dragging_node.global_position if _dragging_node != null else
			Vector2.ZERO
	)
	for i in children.size():
		if children[i] is not Control:
			continue
		var child_control := children[i] as Control

		var child_xform: Transform2D = (
				_children_xforms_start[i].interpolate_with(
						_children_xforms_end[i], progress_eased
				)
		)
		child_control.size = _children_sizes_start[i].lerp(
				_children_sizes_end[i], progress_eased
		)
		child_control.position = (
				child_xform.origin
				- child_xform.basis_xform(child_control.size * 0.5)
		)
		child_control.rotation = child_xform.get_rotation()
		child_control.scale = child_xform.get_scale()

	if _dragging_node != null:
		_dragging_node.global_position = dragged_node_pos

	if _interp_progress_factor >= 1.0:
		set_process(false)


func _input(event: InputEvent) -> void:
	if _dragging_node == null:
		set_process_input(false)
		return

	var dragging_node_movement := Vector2.ZERO

	# Have mouse motion affect the dragging node's position
	if event is InputEventMouseMotion:
		dragging_node_movement += (event as InputEventMouseMotion).relative

	# Have the scroll amount affect the dragging node's position
	if _parent_scroll != null:
		dragging_node_movement += Vector2(
				_parent_scroll.scroll_horizontal - _scroll_horizontal_before,
				_parent_scroll.scroll_vertical - _scroll_vertical_before
		)
		_scroll_horizontal_before = _parent_scroll.scroll_horizontal
		_scroll_vertical_before = _parent_scroll.scroll_vertical

	if dragging_node_movement != Vector2.ZERO:
		if _dragging_node is not Draggable:
			_dragging_node.global_position += dragging_node_movement

		drag_moved.emit(_dragging_node)
		if allow_drag_reorder:
			_insert_child_at_position(_dragging_node)

		if (
				allow_drag_transfer
				and not Rect2(Vector2.ZERO, size).has_point(
						get_global_transform().affine_inverse()
						* get_viewport().get_mouse_position()
				)
		):
			_insert_child_in_other(
					_dragging_node, get_viewport().get_mouse_position()
			)

	if (
			event is InputEventMouseButton
			and
			(event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
			and not (event as InputEventMouseButton).pressed
	):
		drag_ended.emit(_dragging_node)
		_dragging_node = null
		queue_sort()
		set_process_input(false)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SORT_CHILDREN:
		if _skip_next_reorder:
			# Skip sort if custom_minimum_size changed when sorting children.
			# Prevents animation from not playing.
			# _skip_next_reorder is reset next _process()
			return

		var child_count: int = get_child_count(true)
		_children_xforms_start.resize(child_count)
		_children_sizes_start.resize(child_count)
		_children_xforms_end.resize(child_count)
		_children_sizes_end.resize(child_count)
		_sort_children()
		_skip_next_reorder = true
		_interp_progress_factor = 0.0
		set_process(true)


## Sets the target [Rect2] for a child.
## It will be smoothly animated to fit into that rect,
## adhering to [method Control.fit_child_in_rect] constraints.[br]
## Must be called on each child
## during [method _sort_children] to set their target position.
func fit_interpolated(child: Control, rect: Rect2) -> void:
	var child_index: int = child.get_index()

	# New children should be fit in the rect
	# BEFORE setting their starting transform.
	if child in _new_children:
		fit_child_in_rect(child, rect)
		_new_children.erase(child)

	var child_start_xform: Transform2D = child.get_global_transform()
	child_start_xform.origin += child_start_xform.basis_xform(child.size * 0.5)

	_children_xforms_start[child_index] = (
			get_global_transform().affine_inverse() * child_start_xform
	)
	_children_sizes_start[child_index] = child.size
	fit_child_in_rect(child, rect)
	_children_xforms_end[child_index] = Transform2D(
			Vector2(1, 0), Vector2(0, 1), child.position + child.size * 0.5
	)
	_children_sizes_end[child_index] = child.size


## Reorder children by a comparator function,
## similar to [method Array.sort_custom]. [br]
## Not to be confused with [method _sort_children],
## which is a method you must override in a script
## to define child positions and sizes when the container updates.
func sort_children_by_expression(expr: Callable) -> void:
	var children: Array[Node] = get_children(true)
	children.sort_custom(expr)
	for i in children.size():
		if children[i].get_index() != i:
			children[i].get_parent().move_child(children[i], i)


## Forcibly releases children that are being dragged.
func force_release() -> void:
	drag_ended.emit(_dragging_node)
	_dragging_node = null
	queue_sort()
	set_process_input(false)


func _get_minimum_size() -> Vector2:
	return cached_minimum_size


## Override to define the behaviour
## for dragging a node via drag-and-drop rearrangement. [br]
## Should emit [signal order_changed]
## if the node's index was successfully changed.
func _insert_child_at_position(_child: Control) -> void:
	pass


## Override to define positions of all child nodes. [br]
## Must change [member cached_minimum_size]
## to update own size for parent containers. [br]
## Must call [method fit_interpolated] on each child to set their position.
func _sort_children() -> void:
	pass


func _insert_child_in_other(
		child: Control, mouse_global_position: Vector2
) -> void:
	for box in _all_boxes:
		if (
				not box.allow_drag_insert
				or not Rect2(Vector2.ZERO, box.size).has_point(
						box.get_global_transform().affine_inverse()
						* mouse_global_position
				)
		):
			continue

		if (
				box.drag_max_count > -1
				and box.get_child_count(true) >= box.drag_max_count
		):
			continue

		if (
				box._drag_insert_condition_exp != null
				and not box._drag_insert_condition_exp.execute(
						[self, box], child
				)
		):
			continue

		child.reparent(box)
		box._dragging_node = child
		box.set_process_input(true)
		set_process_input(false)
		if not drag_insert_call_on_success.is_empty():
			# Can be compiled on the spot - not called as often.
			var success_expr := Expression.new()
			success_expr.parse(drag_insert_call_on_success)
			success_expr.execute([self, box], child)

		drag_transfered_out.emit(child, box)
		box.drag_transfered_in.emit(child, self)
		break


func _on_child_entered_tree(child: Node) -> void:
	if child is Control:
		var child_control := child as Control
		child_control.gui_input.connect(_on_child_gui_input.bind(child))
		_new_children.append(child_control)

	set_process(false)


func _on_child_exiting_tree(child: Node) -> void:
	if child is Control:
		(child as Control).gui_input.disconnect(_on_child_gui_input)
		_new_children.erase(child)


func _on_child_gui_input(event: InputEvent, child: Control) -> void:
	if not allow_drag_reorder and not allow_drag_transfer:
		return

	if (
			event is InputEventMouseButton
			and
			(event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT
			and (event as InputEventMouseButton).pressed
	):
		_dragging_node = child

		if _parent_scroll != null:
			_scroll_horizontal_before = _parent_scroll.scroll_horizontal
			_scroll_vertical_before = _parent_scroll.scroll_vertical

		drag_started.emit(child)
		set_process_input(true)
