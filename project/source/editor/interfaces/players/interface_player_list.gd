class_name InterfacePlayerList
extends AppEditorInterface
## Shows a list of all game players for the user to edit.

signal item_selected(player_id: int)

const _ELEMENT_SCENE := preload("uid://1g15rgahujc") as PackedScene

var game_players: GamePlayers

## Maps player ids to their corresponding node.
var _nodes: Dictionary[int, Node] = {}

@onready var _element_container := %ElementContainer as Node


func _ready() -> void:
	for game_player in game_players.list():
		_add_element(game_player)

	game_players.player_added.connect(_on_player_added)
	game_players.player_removed.connect(_on_player_removed)


func _add_element(game_player: GamePlayer) -> void:
	if _nodes.has(game_player.id):
		push_warning("Player already has a corresponding node.")
		return

	var element := _ELEMENT_SCENE.instantiate() as EditorPlayerListElement
	element.game_player = game_player
	element.pressed.connect(_on_element_pressed)
	_element_container.add_child(element)
	_nodes[game_player.id] = element


func _on_add_button_pressed() -> void:
	var new_player := GamePlayer.new()

	# Set default values
	new_player.player_ai = PlayerAI.from_type(PlayerAI.Type.TESTAI2)
	new_player.player_ai.personality = RandomAIPersonality.new()

	# We need this new player to have a new unique id
	# assigned to it before we can create the undo_redo action
	game_players.add(new_player)

	# Create undo_redo action
	# (don't execute it since we already added the player)
	undo_redo.create_action("Create new player")
	undo_redo.add_do_method(game_players.add.bind(new_player))
	undo_redo.add_undo_method(game_players.remove.bind(new_player))
	undo_redo.commit_action(false)


func _on_element_pressed(element: EditorPlayerListElement) -> void:
	item_selected.emit(element.game_player.id)


func _on_player_added(game_player: GamePlayer, position_index: int) -> void:
	_add_element(game_player)
	_element_container.move_child(_nodes[game_player.id], position_index)


func _on_player_removed(game_player: GamePlayer) -> void:
	if not _nodes.has(game_player.id):
		push_warning("Player doesn't have a corresponding node.")
		return

	_element_container.remove_child(_nodes[game_player.id])
	_nodes.erase(game_player.id)
