class_name PlayerAssignations
## A list of which [Player] username is assigned to which [GamePlayer] id.
## Emits a signal when the list is modified.

signal changed()

## Maps a [Player]'s username to the id of the [GamePlayer] it is playing as.
## Do not edit this list directly!
var map: Dictionary[String, int] = {}


func assign(username: String, game_player_id: int) -> void:
	if map.get(username) == game_player_id:
		return
	map[username] = game_player_id
	changed.emit()


func unassign(username: String) -> void:
	if not map.has(username):
		return
	map.erase(username)
	changed.emit()


## No effect if the old username is not on the list,
## or if the new username is already on the list.
func rename(old_username: String, new_username: String) -> void:
	if not map.has(old_username) or map.has(new_username):
		return

	map[new_username] = map[old_username]
	map.erase(old_username)
	changed.emit()


## Assigns all given usernames to given id.
func assign_list(usernames: Array[String], game_player_id: int) -> void:
	for username in usernames:
		assign(username, game_player_id)


## Unassigns all given usernames.
func unassign_list(usernames: Array[String]) -> void:
	for username in usernames:
		unassign(username)


func undo_redo_add(
		username: String, game_player_id: int, undo_redo: UndoRedoResource
) -> void:
	if map.has(username):
		return

	undo_redo.create_action("Add player assignation")
	undo_redo.add_do_method(assign.bind(username, game_player_id))
	undo_redo.add_undo_method(unassign.bind(username))
	undo_redo.commit_action()


func undo_redo_remove(username: String, undo_redo: UndoRedoResource) -> void:
	if not map.has(username):
		return

	undo_redo.create_action("Remove player assignation")
	undo_redo.add_do_method(unassign.bind(username))
	undo_redo.add_undo_method(assign.bind(username, map[username]))
	undo_redo.commit_action()


func undo_redo_reassign(
		username: String, game_player_id: int, undo_redo: UndoRedoResource
) -> void:
	if not map.has(username):
		undo_redo_add(username, game_player_id, undo_redo)
		return

	# Do nothing if target is already the desired value
	if map[username] == game_player_id:
		return

	undo_redo.create_action("Change target of player assignation")
	undo_redo.add_do_method(assign.bind(username, game_player_id))
	undo_redo.add_undo_method(assign.bind(username, map[username]))
	undo_redo.commit_action()


func undo_redo_rename(
		old_username: String, new_username: String, undo_redo: UndoRedoResource
) -> void:
	if not map.has(old_username) or map.has(new_username):
		return

	undo_redo.create_action("Change username of player assignation")
	undo_redo.add_do_method(rename.bind(old_username, new_username))
	undo_redo.add_undo_method(rename.bind(new_username, old_username))
	undo_redo.commit_action()
