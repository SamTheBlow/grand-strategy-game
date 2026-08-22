class_name InterfacePlayerList
extends AppEditorInterface
## Shows a list of all game players for the user to edit.

const _ELEMENT_SCENE := preload("uid://1g15rgahujc") as PackedScene

## Maps player ids to their corresponding node.
var _nodes: Dictionary[int, Node] = {}

@onready var _element_container := %ElementContainer as Node


func _ready() -> void:
	for game_player in project.game.game_players.list():
		_add_element(game_player)

	if _nodes.is_empty():
		_add_empty_list_label()

	project.game.game_players.added.connect(_on_player_added)
	project.game.game_players.removed.connect(_on_player_removed)

	const COMPONENT_KEYS: Array[String] = [
		PlayerCreation.KEY,
		PlayerAssignmentToCountry.KEY
	]
	var components_section := %ComponentSection as ComponentSection
	components_section.setup(COMPONENT_KEYS, project, undo_redo)

	closed.connect(navigator.close_interface)


func _add_empty_list_label() -> void:
	var empty_list_label := Label.new()
	empty_list_label.text = "(There are no players.)"
	empty_list_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	empty_list_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	empty_list_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	empty_list_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_element_container.add_child(empty_list_label)


func _remove_empty_list_label() -> void:
	NodeUtils.remove_all_children(_element_container)


func _add_element(game_player: GamePlayer) -> void:
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
	var game_players: GamePlayers = project.game.game_players
	game_players.add(new_player)

	# Create undo_redo action
	# (don't execute it since we already added the player)
	undo_redo.create_action("Create new player")
	undo_redo.add_do_method(game_players.add.bind(new_player))
	undo_redo.add_undo_method(game_players.remove.bind(new_player))
	undo_redo.commit_action(false)


func _on_element_pressed(element: EditorPlayerListElement) -> void:
	navigator.open_player_edit_interface(element.game_player)


func _on_player_added(game_player: GamePlayer) -> void:
	if _nodes.is_empty():
		_remove_empty_list_label()

	_add_element(game_player)
	_element_container.move_child(
			_nodes[game_player.id],
			project.game.game_players.find(game_player)
	)


func _on_player_removed(game_player: GamePlayer) -> void:
	_element_container.remove_child(_nodes[game_player.id])
	_nodes.erase(game_player.id)

	if _nodes.is_empty():
		_add_empty_list_label()
