class_name ProjectLoadPopup
extends VBoxContainer
## The popup that appears when the user wishes to load a [GameProject].
##
## See also: [GamePopup]

signal project_loaded(project: GameProject)

@export var _builtin_game_file_paths: Array[String]

## May be null, in which case no project is currently selected.
var _selected_project: GameOptionNode = null

@onready var _builtin_games := %BuiltInGames as Collapsible
@onready var _imported_games := %ImportedGames as Collapsible


func _ready() -> void:
	_imported_games.hide()

	for project_file_path in _builtin_game_file_paths:
		var metadata: ProjectMetadata = (
				ProjectMetadata.from_file_path(project_file_path)
		)
		if metadata == null:
			push_error("Built-in game file path is invalid.")
			continue

		_add_project(metadata, _builtin_games)


func buttons() -> Array[String]:
	return ["Cancel", "Load"]


func _add_project(
		project_metadata: ProjectMetadata,
		container_node: Collapsible,
		select_project: bool = false
) -> void:
	var option_node := (
			preload("uid://b65o5apaw32").instantiate() as GameOptionNode
	)
	option_node.metadata = project_metadata
	option_node.selected.connect(_on_project_selected)
	container_node.add_node(option_node)

	if select_project:
		_select_project(option_node)


func _select_project(option_node: GameOptionNode) -> void:
	if _selected_project != null:
		_selected_project.deselect()

	_selected_project = option_node
	option_node.select()


func _on_button_pressed(button_id: int) -> void:
	if button_id == 1:
		# Prevent crash if no project is selected
		if _selected_project == null:
			return

		var project_parse_result: ProjectParsing.ParseResult = (
				ProjectFromPath.loaded_from(
						_selected_project.metadata.file_path
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


func _on_project_selected(option_node: GameOptionNode) -> void:
	_select_project(option_node)


func _on_project_imported(project_metadata: ProjectMetadata) -> void:
	_imported_games.show()
	_add_project(project_metadata, _imported_games, true)
	await get_tree().process_frame
	_imported_games.expand()
