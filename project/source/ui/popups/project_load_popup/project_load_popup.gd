class_name ProjectLoadPopup
extends VBoxContainer
## Allows the user to load an existing project.
##
## See also: [GamePopup]

signal project_loaded(project: GameProject)

## May be null, in which case no project is currently selected.
var _selected_option: GameOptionNode = null:
	set = _set_selected_option


func _set_selected_option(value: GameOptionNode) -> void:
	if _selected_option != null:
		_selected_option.deselect()

	_selected_option = value

	if _selected_option != null:
		_selected_option.select()


func buttons() -> Array[String]:
	return ["Cancel", "Load"]


func _on_button_pressed(button_id: int) -> void:
	if button_id == 1:
		# Prevent crash if no project is selected
		if _selected_option == null:
			return

		var project_parse_result: ProjectParsing.ParseResult = (
				ProjectFromPath.loaded_from(
						_selected_option.meta_bundle.project_absolute_path
				)
		)

		if project_parse_result.error:
			# TODO show error to user
			push_warning(
					"Failed to load project: ",
					project_parse_result.error_message
			)
			return

		project_loaded.emit(project_parse_result.result_project)
