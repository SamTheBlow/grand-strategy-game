class_name GameSelectionMenu
extends MarginContainer
## Allows the user to select a game to play.
## Shows all the available games (built-in and imported).
## Has buttons for importing (or scanning for) games.
## Clicking on a game selects it and emits a signal.
## There must be a game selected, and only one game can be selected at a time.

@export var _play_menu_settings: PlayMenuSettings

var _selected_game_node: GameOptionNode

@onready var _game_list_builtin := %GameListBuiltin as GameListBuiltin
@onready var _game_list_imported := %GameListImported as GameListNode
@onready var _scroll_builtin := %ScrollBuiltin as ScrollContainer
@onready var _scroll_custom := %ScrollImported as ScrollContainer


func _ready() -> void:
	_refresh(_play_menu_settings.game_select_menu_state)
	_play_menu_settings.state_changed.connect(_on_state_changed)


func selected_game() -> MetadataBundle:
	return _selected_game_node.meta_bundle


## Returns null if there is no [GameOptionNode] with given id.
func _option_node_with_id(game_id: int) -> GameOptionNode:
	for game_list: GameListNode in [_game_list_builtin, _game_list_imported]:
		var option_node: GameOptionNode = game_list.game_with_id(game_id)
		if option_node != null:
			return option_node
	return null


func _refresh(state: GameSelectMenuState) -> void:
	state.selected_game_changed.connect(_on_project_selected)
	state.imported_game_added.connect(_on_imported_game_added)

	# Load the built-in games if they aren't loaded already
	if state.builtin_games().size() == 0:
		for file_path in _game_list_builtin.builtin_games:
			var parse_result := MetadataBundle.from_path(file_path)
			if parse_result.error:
				continue
			state.add_builtin_game(parse_result.result)

	# Clear existing nodes
	_game_list_builtin.clear()
	_game_list_imported.clear()

	# Load the [GameOptionNode]s
	var builtin_games: Array[MetadataBundle] = state.builtin_games()
	_game_list_builtin.add_games(builtin_games, 0)
	_game_list_imported.add_games(state.imported_games(), builtin_games.size())

	# If no game is selected, select the first game on the list by default
	if state.selected_game_id() == -1:
		state.set_selected_game_id(0)

	# Highlight the selected game
	_on_project_selected()

	# Scroll down so that the selected game is visible on screen
	_scroll_to_selected_game()


func _scroll_to_selected_game() -> void:
	if _selected_game_node == null:
		return

	# This needs to wait two frames, otherwise the scroll bar
	# will not update on clients. I don't know why.
	await get_tree().process_frame
	await get_tree().process_frame

	if _play_menu_settings.game_select_menu_state.is_selected_game_builtin():
		_scroll_builtin.ensure_control_visible(_selected_game_node)
	else:
		_scroll_custom.ensure_control_visible(_selected_game_node)


func _on_state_changed(
		old_value: GameSelectMenuState, new_value: GameSelectMenuState
) -> void:
	old_value.selected_game_changed.disconnect(_on_project_selected)
	old_value.imported_game_added.disconnect(_on_imported_game_added)
	_refresh(new_value)


## Called when the user clicks on a game to select it.
func _on_game_clicked(game_id: int) -> void:
	_play_menu_settings.game_select_menu_state.set_selected_game_id(game_id)


## Called when the [GameSelectMenuState] emits "selected_game_changed".
func _on_project_selected() -> void:
	if _selected_game_node != null:
		_selected_game_node.deselect()

	var game_node: GameOptionNode = _option_node_with_id(
			_play_menu_settings.game_select_menu_state.selected_game_id()
	)
	if game_node == null:
		push_error(
				"Cannot find option node in game selection menu (id: %s)"
				% _play_menu_settings.game_select_menu_state.selected_game_id()
		)
		return

	_selected_game_node = game_node
	_selected_game_node.select()


func _on_imported_game_added(meta_bundle: MetadataBundle) -> void:
	_game_list_imported.add_game(
			meta_bundle,
			_play_menu_settings.game_select_menu_state.number_of_games() - 1
	)


func _on_project_imported(meta_bundle: MetadataBundle) -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		return
	_play_menu_settings.game_select_menu_state.add_imported_game(meta_bundle)
