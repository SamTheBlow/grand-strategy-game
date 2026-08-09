class_name ProvinceLinkEditer
extends Node
## Adds/removes a right clicked province from the selected province's links.
## Clears selected province's links when double right clicked.

@export var _undo_redo: UndoRedoResource

var _province_selection: ProvinceSelection


func _on_world_loaded(world_visuals: WorldVisuals2D) -> void:
	_province_selection = world_visuals.province_selection


func _on_province_right_clicked(
		is_double_click: bool, province_visuals: ProvinceVisuals2D
) -> void:
	var selected_province: Province = _province_selection.selected_province
	if selected_province == null:
		return

	var clicked_province_id: int = province_visuals.province.id

	# Double right click the selected province to remove all its links
	if clicked_province_id == selected_province.id:
		# No effect when single clicking selected province
		if not is_double_click:
			return

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
