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


func _ready() -> void:
	for project_file_path in _builtin_game_file_paths:
		var metadata: GameMetadata = (
				GameMetadata.from_file_path(project_file_path)
		)
		if metadata == null:
			push_error("Built-in game file path is invalid.")
			continue

		var new_option := (
				preload("uid://b65o5apaw32").instantiate() as GameOptionNode
		)
		new_option.metadata = metadata
		new_option.selected.connect(_on_project_selected)
		_builtin_games.add_node(new_option)


func buttons() -> Array[String]:
	return ["Cancel", "Load"]


func _on_button_pressed(button_id: int) -> void:
	if button_id == 1:
		# Prevent crash if no project is selected
		if _selected_project == null:
			return

		var project_parse_result: ProjectFromPath.ParseResult = (
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
	if _selected_project != null:
		_selected_project.deselect()

	_selected_project = option_node
	option_node.select()
