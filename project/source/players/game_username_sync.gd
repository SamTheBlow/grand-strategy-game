class_name GameUsernameSync
extends Node
## Listens to username changes in given [GamePlayers].
## The server sends changes to all clients, and clients update accordingly.
# TODO If a username is changed before this node is ready on a client,
# the client will never receive the new username.

var _game_players: GamePlayers


func _init(game_players: GamePlayers) -> void:
	_game_players = game_players


func _enter_tree() -> void:
	# The node needs to have the same name across all clients,
	# otherwise synchronization will fail.
	name = "UsernameSync"


func _ready() -> void:
	_game_players.username_changed.connect(_on_username_changed)


## Clients receive a username change from the server.
@rpc("authority", "call_remote", "reliable")
func _receive_username_change(
		game_player_id: int, new_username: String
) -> void:
	var game_player: GamePlayer = _game_players.player_from_id(game_player_id)
	if game_player == null:
		push_warning("Received an invalid GamePlayer id from the server.")
		return

	game_player.username = new_username


func _on_username_changed(game_player: GamePlayer) -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		return

	_receive_username_change.rpc(game_player.id, game_player.username)
