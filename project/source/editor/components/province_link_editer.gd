class_name ProvinceLinkEditer
extends Node
## Adds/removes the overlay for polygon editing.
##
## Adds/removes a right clicked province from the selected province's links.
## Clears selected province's links when double right clicked.

signal overlay_created(node: Node)

var is_enabled: bool = false:
	set(value):
		is_enabled = value
		_refresh()

var _province_container: ProvinceVisualsContainer2D
var _province_selection: ProvinceSelection
var _edge_case: PolygonEditEdgeCase

var _undo_redo := UndoRedo.new()

## May be null.
var _world_overlay: Node = null:
	set(value):
		if _world_overlay != null:
			NodeUtils.delete_node(_world_overlay)
		_world_overlay = value
		if _world_overlay != null:
			overlay_created.emit(_world_overlay)


func _exit_tree() -> void:
	# Destroy the overlay
	_world_overlay = null


func setup(
		province_container: ProvinceVisualsContainer2D,
		province_selection: ProvinceSelection,
		edge_case: PolygonEditEdgeCase
) -> void:
	_province_container = province_container
	_province_selection = province_selection
	_edge_case = edge_case

	_province_selection.province_selected.connect(_refresh.unbind(1))

	if is_node_ready():
		_refresh()
	else:
		ready.connect(_refresh, ConnectFlags.CONNECT_ONE_SHOT)


## Adds/removes the overlay for polygon editing
func _refresh() -> void:
	if not is_enabled or not is_node_ready():
		_world_overlay = null
		return

	var selected_province: Province = _province_selection.selected_province()
	if selected_province == null:
		_world_overlay = null
		return

	var province_visuals: ProvinceVisuals2D = (
			_province_container.visuals_of(selected_province.id)
	)
	if province_visuals == null:
		_world_overlay = null
		return

	var world_overlay := Node2D.new()

	var polygon_edit := PolygonEdit.new()
	polygon_edit.polygon = selected_province.polygon()
	polygon_edit.is_draw_polygon_enabled = false
	polygon_edit.undo_redo = _undo_redo
	_edge_case.polygon_edit = polygon_edit
	world_overlay.add_child(polygon_edit)

	var army_position_edit := PositionEdit.new(
			"Army position", PositionEdit.PointShape.SQUARE
	)
	army_position_edit.position = selected_province.position_army_host
	world_overlay.add_child(army_position_edit)

	selected_province.position_army_host_changed.connect(
			army_position_edit.set_position
	)
	army_position_edit.position_changed.connect(
			_on_army_position_changed.bind(selected_province)
	)
	army_position_edit.drag_finished.connect(
			_on_army_drag_finished.bind(selected_province)
	)

	var fortress_position_edit := PositionEdit.new(
			"Fortress position", PositionEdit.PointShape.SQUARE
	)
	fortress_position_edit.position = selected_province.position_fortress
	world_overlay.add_child(fortress_position_edit)

	selected_province.position_fortress_changed.connect(
			fortress_position_edit.set_position
	)
	fortress_position_edit.position_changed.connect(
			_on_fortress_position_changed.bind(selected_province)
	)
	fortress_position_edit.drag_finished.connect(
			_on_fortress_drag_finished.bind(selected_province)
	)

	_world_overlay = world_overlay


func _on_history_initialized(undo_redo: UndoRedo) -> void:
	_undo_redo = undo_redo


func _on_army_position_changed(
		new_position: Vector2, province: Province
) -> void:
	province.position_army_host = new_position


func _on_fortress_position_changed(
		new_position: Vector2, province: Province
) -> void:
	province.position_fortress = new_position


func _on_army_drag_finished(
		start_position: Vector2, end_position: Vector2, province: Province
) -> void:
	if start_position == end_position:
		return

	# Note: we don't execute it since the position was already changed.
	_undo_redo.create_action("Move army in province")
	_undo_redo.add_do_property(province, &"position_army_host", end_position)
	_undo_redo.add_undo_property(
			province, &"position_army_host", start_position
	)
	_undo_redo.commit_action(false)


func _on_fortress_drag_finished(
		start_position: Vector2, end_position: Vector2, province: Province
) -> void:
	if start_position == end_position:
		return

	# Note: we don't execute it since the position was already changed.
	_undo_redo.create_action("Move fortress in province")
	_undo_redo.add_do_property(province, &"position_fortress", end_position)
	_undo_redo.add_undo_property(province, &"position_fortress", start_position)
	_undo_redo.commit_action(false)


func _on_province_right_clicked(
		is_double_click: bool, province_visuals: ProvinceVisuals2D
) -> void:
	var selected_province: Province = _province_selection.selected_province()
	if selected_province == null:
		return

	var clicked_province_id: int = province_visuals.province.id

	# Double right click the selected province to remove all its links
	if is_double_click and clicked_province_id == selected_province.id:
		# Keep track of the linked provinces for undo/redo
		var linked_province_ids: Array[int] = (
				selected_province.linked_province_ids().duplicate()
		)

		_undo_redo.create_action("Reset province's linked provinces")
		_undo_redo.add_do_method(selected_province.reset_links)
		for linked_province_id in linked_province_ids:
			_undo_redo.add_undo_method(
					selected_province.add_link.bind(linked_province_id)
			)
		_undo_redo.commit_action()

		get_viewport().set_input_as_handled()
		return

	# Right click a province to toggle
	# whether or not it's linked to the selected province
	if selected_province.is_linked_to(clicked_province_id):
		_undo_redo.create_action("Remove province link")
		_undo_redo.add_do_method(
				selected_province.remove_link.bind(clicked_province_id)
		)
		_undo_redo.add_undo_method(
				selected_province.add_link.bind(clicked_province_id)
		)
	else:
		_undo_redo.create_action("Add province link")
		_undo_redo.add_do_method(
				selected_province.add_link.bind(clicked_province_id)
		)
		_undo_redo.add_undo_method(
				selected_province.remove_link.bind(clicked_province_id)
		)
	_undo_redo.commit_action()

	get_viewport().set_input_as_handled()
