class_name GamePlayerListNode
extends Control
## Displays a list of [GamePlayer]s as buttons.
## Clicking on a player emits a signal.

signal game_player_selected(game_player: GamePlayer)

const _ELEMENT_SCENE: PackedScene = preload("uid://1g15rgahujc")

## Maps game players to their corresponding node.
var _nodes: Dictionary[GamePlayer, Node] = {}

@onready var _element_container := %GamePlayerContainer as Node


func setup(game_players: GamePlayers) -> void:
	if not is_node_ready():
		await ready

	for game_player in game_players.list:
		_add_element(game_player)

	if _nodes.is_empty():
		_add_empty_list_label()

	game_players.added.connect(_add_element)
	game_players.removed.connect(_remove_element)


func _add_empty_list_label() -> void:
	var empty_list_label := Label.new()
	empty_list_label.text = "(There are no players.)"
	empty_list_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	empty_list_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	empty_list_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_list_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_element_container.add_child(empty_list_label)


func _remove_empty_list_label() -> void:
	NodeUtils.delete_all_children(_element_container)


func _add_element(game_player: GamePlayer) -> void:
	if _nodes.has(game_player):
		push_warning("GamePlayer already has a corresponding node.")
		return

	if _nodes.is_empty():
		_remove_empty_list_label()

	var new_element := _ELEMENT_SCENE.instantiate() as EditorPlayerListElement
	new_element.game_player = game_player
	new_element.pressed.connect(_on_element_pressed)
	_element_container.add_child(new_element)
	_nodes[game_player] = new_element


func _remove_element(game_player: GamePlayer) -> void:
	if not _nodes.has(game_player):
		push_warning("GamePlayer doesn't have a corresponding node.")
		return

	_element_container.remove_child(_nodes[game_player])
	_nodes.erase(game_player)

	if _nodes.is_empty():
		_add_empty_list_label()


func _on_element_pressed(element: EditorPlayerListElement) -> void:
	game_player_selected.emit(element.game_player)
