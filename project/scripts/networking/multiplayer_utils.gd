class_name MultiplayerUtils
## Utility class for online multiplayer functions.


## Returns true if (and only if) you are connected online.
## It will return true whether or not you are the server.
static func is_online(multiplayer: MultiplayerAPI) -> bool:
	return (
			multiplayer
			and multiplayer.has_multiplayer_peer()
			and (not multiplayer.multiplayer_peer is OfflineMultiplayerPeer)
			and multiplayer.multiplayer_peer.get_connection_status()
			== MultiplayerPeer.CONNECTION_CONNECTED
	)


## Returns true if (and only if) you are connected online as the server.
static func is_server(multiplayer: MultiplayerAPI) -> bool:
	return is_online(multiplayer) and multiplayer.is_server()


## Returns true if (and only if) you are either not connected online,
## or you are connected online as the server.
## In other words, this only returns false when
## you are connected online and you are not the server.
static func has_authority(multiplayer: MultiplayerAPI) -> bool:
	return (not is_online(multiplayer)) or multiplayer.is_server()


## Returns true if you represent the given player.
static func has_gameplay_authority(
		multiplayer: MultiplayerAPI, player: GamePlayer
) -> bool:
	return not (
			is_online(multiplayer)
			and player.player_human and player.player_human.is_remote()
	)
