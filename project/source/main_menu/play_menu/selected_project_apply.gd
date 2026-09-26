extends Node
## Applies the currently selected project according to the [PlayMenuSettings].
## If none are selected, selects the first one in the lists.

@export var _play_menu_settings: PlayMenuSettings
@export var _scroll_container: ScrollContainer
@export var _project_lists: Array[ProjectOptionContainer] = []


func _ready() -> void:
	# Other nodes are expected to react to the project node being selected.
	# Wait for other nodes to be ready.
	await get_tree().process_frame

	var file_path: String = _play_menu_settings.selected_project_file_path
	var first_option_found: GameOptionNode = null
	for project_list in _project_lists:
		if first_option_found == null and not project_list.projects.is_empty():
			first_option_found = project_list.projects.values()[0]

		# There is no selected project -> select the first option you find
		if file_path.is_empty():
			if first_option_found != null:
				break
			else:
				continue

		# There is a selected project -> select its corresponding node
		if project_list.projects.has(file_path):
			_select_option(project_list.projects[file_path])
			return

	# Could not find corresponding option -> select the first option we found
	_select_option(first_option_found)


func _select_option(option_to_select: GameOptionNode) -> void:
	option_to_select.selected.emit(option_to_select)

	# We need to wait two frames
	# before the scroll container can do its thing.
	await get_tree().process_frame
	await get_tree().process_frame
	_scroll_container.ensure_control_visible(option_to_select)
