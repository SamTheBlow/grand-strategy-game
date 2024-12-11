class_name MultiplayerUtils
## Provides utility functions related to online multiplayer.


## Returns true if you are connected online.
## You are a server, a client, or a client in the process of authentication.
static func is_connected_online(multiplayer: MultiplayerAPI) -> bool:
	return (
			multiplayer
			and multiplayer.has_multiplayer_peer()
			and (not multiplayer.multiplayer_peer is OfflineMultiplayerPeer)
			and multiplayer.multiplayer_peer.get_connection_status()
			== MultiplayerPeer.CONNECTION_CONNECTED
	)


## Returns true if you are connected online, either as a server or a client.
## Returns false if you are a client in the process of authentication.
static func is_online(multiplayer: MultiplayerAPI) -> bool:
	return (
			is_connected_online(multiplayer)
			and (multiplayer.is_server() or multiplayer.get_peers().has(1))
	)


## Returns true if you are connected online as the server.
static func is_server(multiplayer: MultiplayerAPI) -> bool:
	return is_connected_online(multiplayer) and multiplayer.is_server()


## Returns true if you are a client going through an authentification process.
static func is_authenticating(multiplayer: MultiplayerAPI) -> bool:
	# When you're connected but 1 (the server) isn't in the list of peers,
	# it means you're still in the authentication process.
	return (
			is_connected_online(multiplayer)
			and not (multiplayer.is_server() or multiplayer.get_peers().has(1))
	)


## Returns true if (and only if) you are either not connected online,
## or you are connected online as the server.
## In other words, this only returns false when
## you are connected online and you are not the server.
static func has_authority(multiplayer: MultiplayerAPI) -> bool:
	return (not is_online(multiplayer)) or multiplayer.is_server()


## Returns true if you represent the given player.
## In other words, the given player is a human player and isn't a remote player.
static func has_gameplay_authority(
		multiplayer: MultiplayerAPI, player: GamePlayer
) -> bool:
	return player.is_human and not (
			is_online(multiplayer)
			and player.player_human != null
			and player.player_human.is_remote()
	)


## Prints given message with a colored title telling if the user is offline,
## a server, or a client. If they're a client, shows their unique peer id.
## Useful for debugging networking features.
##
## Gray: offline
## Cyan: server
## Blue: client
## Purple: client (authenticating)
static func printn(multiplayer: MultiplayerAPI, message: Variant) -> void:
	var multiplayer_status: String = "OFFLINE"
	var message_color: String = "gray"
	if MultiplayerUtils.is_authenticating(multiplayer):
		multiplayer_status = "CLIENT " + str(multiplayer.get_unique_id())
		message_color = "MEDIUM_PURPLE"
	elif MultiplayerUtils.is_online(multiplayer):
		if multiplayer.is_server():
			multiplayer_status = "SERVER"
			message_color = "cyan"
		else:
			multiplayer_status = "CLIENT " + str(multiplayer.get_unique_id())
			message_color = "CORNFLOWER_BLUE"

	print_rich(
			"[color=", message_color, "][", multiplayer_status, "][/color] ",
			message
	)
