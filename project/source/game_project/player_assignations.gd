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


## Assigns all given usernames to given id.
func assign_list(usernames: Array[String], game_player_id: int) -> void:
	for username in usernames:
		assign(username, game_player_id)


## Unassigns all given usernames.
func unassign_list(usernames: Array[String]) -> void:
	for username in usernames:
		unassign(username)
