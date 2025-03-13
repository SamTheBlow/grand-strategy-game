class_name GameSelectionMenu
extends MarginContainer
## In the main menu, this is the tab for choosing the game to play.
## Shows all the available games (built-in and imported).
## Has buttons for importing (or scanning for) games.
## Clicking on a game selects it and emits a signal.
## There must be a game selected, and only one game can be selected at a time.

var game_menu_state: GameSelectMenuState:
	set = set_game_menu_state

var _selected_game_node: GameOptionNode

@onready var _sync := %MenuSync as GameSelectMenuSync
@onready var _import_dialog := %ImportDialog as FileDialog
@onready var _game_list_builtin: GameListBuiltin = (
		%GameListBuiltin as GameListBuiltin
)
@onready var _game_list_imported: GameListNode = (
		%GameListImported as GameListNode
)
@onready var _scroll_builtin := %ScrollBuiltin as ScrollContainer
@onready var _scroll_custom := %ScrollImported as ScrollContainer


func _ready() -> void:
	_update_game_menu_state()


# This is its own function so that other nodes can have signals that call this.
func set_game_menu_state(value: GameSelectMenuState) -> void:
	_disconnect_signals()
	game_menu_state = value
	_connect_signals()
	_update_game_menu_state()


func selected_game() -> GameMetadata:
	return _selected_game_node.metadata


## Returns null if there is no [GameOptionNode] with given id.
func _option_node_with_id(game_id: int) -> GameOptionNode:
	for game_list: GameListNode in [_game_list_builtin, _game_list_imported]:
		var option_node: GameOptionNode = game_list.game_with_id(game_id)
		if option_node != null:
			return option_node
	return null


func _update_game_menu_state() -> void:
	if game_menu_state == null or not is_node_ready():
		return

	_sync.active_state = game_menu_state
	# Only set the current state as the local state
	# the first time this function is called.
	if _sync.local_state == null:
		_sync.local_state = game_menu_state

	(%GameImport as GameImport).game_menu_state = game_menu_state

	# Load the built-in games if they aren't loaded already
	if game_menu_state.builtin_games().size() == 0:
		for builtin_game_file_path in _game_list_builtin.builtin_games:
			var builtin_game: GameMetadata = (
					GameMetadata.from_file_path(builtin_game_file_path)
			)
			if builtin_game == null:
				continue
			game_menu_state.add_builtin_game(builtin_game)

	# Clear existing nodes
	_game_list_builtin.clear()
	_game_list_imported.clear()

	# Load the [GameOptionNode]s
	var builtin_games: Array[GameMetadata] = game_menu_state.builtin_games()
	_game_list_builtin.add_games(builtin_games, 0)
	_game_list_imported.add_games(
			game_menu_state.imported_games(), builtin_games.size()
	)

	# If no game is selected, select the first game on the list by default
	if game_menu_state.selected_game_id() == -1:
		game_menu_state.set_selected_game_id(0)

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

	if game_menu_state.is_selected_game_builtin():
		_scroll_builtin.ensure_control_visible(_selected_game_node)
	else:
		_scroll_custom.ensure_control_visible(_selected_game_node)


func _connect_signals() -> void:
	if game_menu_state == null:
		return

	if not game_menu_state.selected_game_changed.is_connected(
			_on_project_selected
	):
		game_menu_state.selected_game_changed.connect(_on_project_selected)
	if not game_menu_state.imported_game_added.is_connected(
			_on_imported_game_added
	):
		game_menu_state.imported_game_added.connect(_on_imported_game_added)
	if not game_menu_state.state_changed.is_connected(_on_state_changed):
		game_menu_state.state_changed.connect(_on_state_changed)


func _disconnect_signals() -> void:
	if game_menu_state == null:
		return

	if game_menu_state.selected_game_changed.is_connected(
			_on_project_selected
	):
		game_menu_state.selected_game_changed.disconnect(_on_project_selected)
	if game_menu_state.imported_game_added.is_connected(
			_on_imported_game_added
	):
		game_menu_state.imported_game_added.disconnect(_on_imported_game_added)
	if game_menu_state.state_changed.is_connected(_on_state_changed):
		game_menu_state.state_changed.disconnect(_on_state_changed)


## Called when the user clicks on a game to select it.
func _on_game_clicked(game_id: int) -> void:
	game_menu_state.set_selected_game_id(game_id)


## Called when the [GameSelectMenuState] emits "selected_game_changed".
func _on_project_selected() -> void:
	if _selected_game_node != null:
		_selected_game_node.deselect()

	var game_node: GameOptionNode = (
			_option_node_with_id(game_menu_state.selected_game_id())
	)
	if game_node == null:
		push_error(
				"Cannot find option node in game selection menu (id: "
				+ str(game_menu_state.selected_game_id()) + ")"
		)
		return

	_selected_game_node = game_node
	_selected_game_node.select()


func _on_imported_game_added(metadata: GameMetadata) -> void:
	var new_game_id: int = game_menu_state.number_of_games() - 1
	_game_list_imported.add_game(metadata, new_game_id)


func _on_state_changed(_state: GameSelectMenuState) -> void:
	_update_game_menu_state()


func _on_import_button_pressed() -> void:
	_import_dialog.show()
