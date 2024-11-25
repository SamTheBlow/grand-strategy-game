class_name GameUsernameSync
extends Node
## Synchronizes username changes in given [GamePlayers].


## Not meant to be set more than once. Not meant to be null.
var game_players: GamePlayers:
	set(value):
		game_players = value
		game_players.username_changed.connect(_on_username_changed)


func _init(game_players_: GamePlayers = null) -> void:
	game_players = game_players_


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = "UsernameSync"


## The client receives a username change from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_username_change(
		game_player_id: int, new_username: String
) -> void:
	var game_player: GamePlayer = game_players.player_from_id(game_player_id)
	if game_player == null:
		push_warning(
				"Received a username change with an invalid game_player_id"
		)
		return

	game_player.username = new_username


func _on_username_changed(game_player: GamePlayer) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_receive_username_change.rpc(game_player.id, game_player.username)
