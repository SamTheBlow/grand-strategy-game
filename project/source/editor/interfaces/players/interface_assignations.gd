class_name InterfaceAssignations
extends Control
## The "Assignations" tab of the [InterfacePlayerList].
## Allows the user to add, remove and edit player assignations
## (which username is assigned to which [GamePlayer]).

signal player_select_requested(callable: Callable)

const _ELEMENT_SCENE: PackedScene = preload("uid://cq2kve5dkrs7u")

var project: GameProject
var undo_redo: UndoRedoResource

## Maps each username to its element node, for quick access.
var _elements: Dictionary[String, AssignationListElement] = {}

@onready var _add_button := %AddButton as Button
@onready var _element_container := %ElementContainer as Node
@onready var _empty_list_label := %EmptyListLabel as Label


func setup(new_project: GameProject, new_undo_redo: UndoRedoResource) -> void:
	project = new_project
	undo_redo = new_undo_redo

	_discard_invalid_assignations()

	_refresh_list()
	project.player_assignations.changed.connect(_refresh_list)

	_refresh_add_button()
	project.game.game_players.added.connect(_refresh_add_button.unbind(1))
	project.game.game_players.removed.connect(_refresh_add_button.unbind(1))


func _discard_invalid_assignations() -> void:
	var invalid_assignations: Array[String] = []
	for username in project.player_assignations.map:
		if not project.game.game_players.map.has(
				project.player_assignations.map[username]
		):
			invalid_assignations.append(username)

	project.player_assignations.unassign_list(invalid_assignations)


## Rebuilds the list using the project data.
func _refresh_list() -> void:
	_remove_empty_list_label()
	NodeUtils.delete_all_children(_element_container)
	_elements.clear()

	for username in project.player_assignations.map:
		var game_player: GamePlayer = project.game.game_players.map.get(
				project.player_assignations.map[username]
		)
		_add_element(username, game_player)

	if _elements.is_empty():
		_add_empty_list_label()


func _add_element(username: String, game_player: GamePlayer) -> void:
	if _elements.is_empty():
		_remove_empty_list_label()

	var element := _ELEMENT_SCENE.instantiate() as AssignationListElement
	element.username = username
	element.game_player = game_player
	element.username_changed.connect(
			_on_username_changed, ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
	)
	element.choose_pressed.connect(_on_choose_player_pressed.bind(username))
	element.delete_pressed.connect(_on_delete_pressed.bind(username))

	_element_container.add_child(element)
	_elements[element.username] = element


func _next_default_username() -> String:
	var index: int = 1
	while _elements.has("Player %s" % index):
		index += 1
	return "Player %s" % index


func _add_empty_list_label() -> void:
	if _empty_list_label.get_parent() == _element_container:
		return
	_element_container.add_child(_empty_list_label)


func _remove_empty_list_label() -> void:
	if _empty_list_label.get_parent() != _element_container:
		return
	_element_container.remove_child(_empty_list_label)


## Disables the "Add" button when the project's [GamePlayers] list is empty.
func _refresh_add_button() -> void:
	_add_button.disabled = project.game.game_players.list.is_empty()


func _on_add_button_pressed() -> void:
	var game_players: Array[GamePlayer] = project.game.game_players.list
	if game_players.is_empty():
		push_warning("GamePlayers list is empty.")
		return

	project.player_assignations.undo_redo_add(
			_next_default_username(), game_players[0].id, undo_redo
	)


func _on_delete_pressed(username: String) -> void:
	project.player_assignations.undo_redo_remove(username, undo_redo)


func _on_username_changed(
		old_value: String, new_value: String, element: AssignationListElement
) -> void:
	# Prevent duplicate entries
	if project.player_assignations.map.has(new_value):
		element.username_changed.disconnect(_on_username_changed)
		element.username = old_value
		element.username_changed.connect(
				_on_username_changed, ConnectFlags.CONNECT_APPEND_SOURCE_OBJECT
		)
		return

	project.player_assignations.undo_redo_rename(
			old_value, new_value, undo_redo
	)


func _on_choose_player_pressed(username: String) -> void:
	player_select_requested.emit(_on_player_selected.bind(username))


func _on_player_selected(game_player: GamePlayer, username: String) -> void:
	if not _elements.has(username):
		return

	project.player_assignations.undo_redo_reassign(
			username, game_player.id, undo_redo
	)
