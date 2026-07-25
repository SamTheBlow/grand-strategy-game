class_name InterfacePlayerList
extends AppEditorInterface
## Shows a list of all game players for the user to edit.

## Emitted when the user selects an item in the list.
signal item_selected(player_id: int)

const _PLAYER_ELEMENT_SCENE := preload("uid://1g15rgahujc") as PackedScene

var _is_setup: bool = false
var _game_players: GamePlayers

## Maps player ids to their corresponding node.
var _nodes: Dictionary[int, Node] = {}

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _item_container := %ItemContainer as Node


func _ready() -> void:
	_editor_settings_node.hide()
	super()

	if _is_setup:
		_update()


func setup(game_players: GamePlayers) -> void:
	if _is_setup and is_node_ready():
		_game_players.player_added.disconnect(_on_player_added)
		_game_players.player_removed.disconnect(_on_player_removed)

	_game_players = game_players
	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	NodeUtils.remove_all_children(_item_container)
	_nodes = {}

	for game_player in _game_players.list():
		_add_element(game_player)

	_game_players.player_added.connect(_on_player_added)
	_game_players.player_removed.connect(_on_player_removed)


func _add_element(game_player: GamePlayer) -> void:
	if _nodes.has(game_player.id):
		push_warning("Player already has a corresponding node.")
		return

	var new_element := (
			_PLAYER_ELEMENT_SCENE.instantiate() as EditorPlayerListElement
	)
	new_element.game_player = game_player
	new_element.pressed.connect(_on_element_pressed)
	_item_container.add_child(new_element)
	_nodes[game_player.id] = new_element


func _on_add_button_pressed() -> void:
	var new_player := GamePlayer.new()

	# We need this new player to have a new unique id
	# assigned to it before we can create the undo_redo action
	_game_players.add_player(new_player)

	# Create undo_redo action
	# (don't execute it since we already added the player)
	undo_redo.create_action("Create new player")
	undo_redo.add_do_method(_game_players.add_player.bind(new_player))
	undo_redo.add_undo_method(_game_players.remove_player.bind(new_player))
	undo_redo.commit_action(false)


func _on_element_pressed(element: EditorPlayerListElement) -> void:
	item_selected.emit(element.game_player.id)


func _on_player_added(game_player: GamePlayer, _position_index: int) -> void:
	_add_element(game_player)


func _on_player_removed(game_player: GamePlayer) -> void:
	if _nodes.has(game_player.id):
		NodeUtils.delete_node(_nodes[game_player.id])
		_nodes.erase(game_player.id)
	else:
		push_warning("Player doesn't have a corresponding node.")
