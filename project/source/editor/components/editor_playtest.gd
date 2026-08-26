class_name EditorPlaytest
extends Node
## Starts and ends a playtest of currently open [GameProject].

const _GAME_SCENE: PackedScene = preload("uid://c74o2ubgawogb")

@export var _editor_node: Node
@export var _project_node: ProjectNode

var _game_node: GameNode = null


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"start_playtest"):
		get_viewport().set_input_as_handled()
		start_playtest.call_deferred()
	elif event.is_action_pressed(&"end_playtest"):
		get_viewport().set_input_as_handled()
		end_playtest.call_deferred()


func start_playtest() -> void:
	if _game_node != null:
		return

	# Create new copy of current project
	var project: GameProject = _project_node.project
	var copy_result: ProjectParsing.ParseResult = ProjectParsing.parsed_from(
			ProjectParsing.to_raw_data(project), project.file_path()
	)
	if copy_result.error:
		push_warning(
				"Failed to copy project for playtest: ",
				copy_result.error_message
		)
		return

	# Setup new game scene instance
	_game_node = _GAME_SCENE.instantiate() as GameNode
	_game_node.project = copy_result.result_project
	# TODO don't rely on main
	var main := get_parent().get_parent()
	_game_node.players = main.players
	_game_node.chat = main.chat
	_game_node.exited.connect(end_playtest)

	# Inform user of keyboard shortcut
	_game_node.chat.send_system_message(
			"Press F8 at any time to end the playtest."
	)

	# Replace editor node with game node
	var parent_node: Node = _editor_node.get_parent()
	parent_node.remove_child(_editor_node)
	parent_node.add_child(_game_node)


func end_playtest() -> void:
	if _game_node == null:
		return

	var parent_node: Node = _game_node.get_parent()
	parent_node.remove_child(_game_node)
	parent_node.add_child(_editor_node)

	_game_node.queue_free()
	_game_node = null
