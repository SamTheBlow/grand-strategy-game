class_name Chat
extends Node
## Class responsible for communication between the different components
## of the chat, namely the chat data and the chat interface.
## - Listens to and handles chat inputs.
## - Emits certain signals when certain chat commands are called by the user.
## - Provides utility functions for manipulating the chat data.
## - Synchronizes the chat data for online multiplayer.
##
## To use, set the chat_data property for the chat data,
## and call connect_chat_interface to connect to a chat interface.
##
## Note that in order for your changes to the chat data to be synchronized
## in online multiplayer, you have to use the functions provided in this
## class, not the functions from ChatData.


signal save_requested()
signal load_requested()
signal exit_to_main_menu_requested()
signal rules_requested()

var chat_data := ChatData.new()


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)


## Call this to listen to a chat interface's inputs.
func connect_chat_interface(chat_interface: ChatInterface) -> void:
	chat_interface.input_submitted.connect(_on_chat_interface_input_submitted)


#region Send all data
## Sends all chat data to whoever requests it.
@rpc("any_peer", "call_remote", "reliable")
func _send_all_data() -> void:
	if not _is_server():
		print_debug(
				"Received a request to send all data, "
				+ "but you are not the server!"
		)
		return
	
	_receive_all_data.rpc_id(
			multiplayer.get_remote_sender_id(), chat_data.all_content()
	)


## The user who requested all chat data receives it.
@rpc("authority", "call_remote", "reliable")
func _receive_all_data(chat_content: String) -> void:
	chat_data.clear()
	chat_data.add_content(chat_content)
#endregion


#region Send global message
## Sends a message to all players. Clients are not allowed to call this.
func send_global_message(text: String) -> void:
	if not _is_connected():
		_receive_global_message(text)
		return
	
	if not _is_server():
		print_debug(
				"Tried to send a global message, "
				+ "but you do not have authority!"
		)
		return
	
	_receive_global_message.rpc(text)


@rpc("any_peer", "call_local", "reliable")
func _receive_global_message(text: String) -> void:
	if multiplayer.get_remote_sender_id() != 1:
		# The player who sent this did not have authority.
		# Probably a hacker? Anyways, deny them permission.
		print_debug(
				"Received a global message from someone "
				+ "who did not have authority!"
		)
		return
	
	chat_data.add_content("[i][color=#404040]" + text + "[/color][/i]")
#endregion


#region Send human message
## Sends to all players a message written by the player.
func send_human_message(text: String) -> void:
	if _is_connected():
		_receive_human_message.rpc(text)
	else:
		_receive_human_message(text)


@rpc("any_peer", "call_local", "reliable")
func _receive_human_message(text: String) -> void:
	var stripped_text: String = text.strip_edges()
	
	if stripped_text == "":
		return
	
	var sender_name: String = "You"
	if (
			_is_connected() and
			multiplayer.get_remote_sender_id() != multiplayer.get_unique_id()
	):
		sender_name = str(multiplayer.get_remote_sender_id())
	
	chat_data.add_content(
			"[color=#202020]" + sender_name + ": [/color][color=#404040]"
			+ stripped_text + "[/color]"
	)
#endregion


## Sends a private message to the player.
func send_system_message(new_text: String) -> void:
	chat_data.add_content(
			"[color=#202020]System: [/color][color=#404040]"
			+ new_text + "[/color]"
	)


## Sends a private message to the player. For convenience.
func send_system_message_multiline(text_lines: Array[String]) -> void:
	var message: String = ""
	for text_line in text_lines:
		message += "\n" + text_line
	send_system_message(message)


## Returns true if (and only if) you are connected.
func _is_connected() -> bool:
	return (
			multiplayer
			and multiplayer.has_multiplayer_peer()
			and multiplayer.multiplayer_peer.get_connection_status()
			== MultiplayerPeer.CONNECTION_CONNECTED
	)


# TODO DRY: copy/pasted from players.gd
## Returns true if (and only if) you are connected and you are the server.
func _is_server() -> bool:
	return _is_connected() and multiplayer.is_server()


## Upon connecting to a server, clients immediately request the
## server's chat data, for synchronization.
func _on_connected_to_server() -> void:
	if multiplayer.is_server():
		return
	_send_all_data.rpc_id(1)


func _on_peer_connected(_multiplayer_id: int) -> void:
	pass


func _on_peer_disconnected(_multiplayer_id: int) -> void:
	pass


func _on_chat_interface_input_submitted(new_text: String) -> void:
	# Submit the message
	if new_text.begins_with("/"):
		# Commands
		var command_args: PackedStringArray = (
				new_text.trim_prefix("/").split(" ")
		)
		var command_name: String = command_args[0]
		command_args.remove_at(0)
		match command_name:
			"help":
				send_system_message_multiline([
						"/help - Get a list of every command",
						"/fs - Toggle fullscreen",
						"/clear - Clear the chat's contents",
						"The commands below only work in-game:",
						"/save - Save the game",
						"/load - Load the saved game",
						"/mainmenu - Go back to the main menu (without saving!)",
						"/rules - Get a list of this game's rules",
				])
			"fs":
				var mode: int = DisplayServer.window_get_mode()
				if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
					DisplayServer.window_set_mode(
							DisplayServer.WINDOW_MODE_WINDOWED
					)
					send_system_message("Switched to windowed")
				else:
					DisplayServer.window_set_mode(
							DisplayServer.WINDOW_MODE_FULLSCREEN
					)
					send_system_message("Switched to fullscreen")
			"clear":
				chat_data.clear()
			"save":
				save_requested.emit()
			"load":
				load_requested.emit()
			"mainmenu":
				exit_to_main_menu_requested.emit()
			"rules":
				rules_requested.emit()
			_:
				send_system_message(
						'"[color=black]' + new_text + '[/color]"'
						+ " is not a valid command"
				)
	else:
		# Not a command
		send_human_message(new_text)


func _on_networking_interface_message_sent(text: String, color: Color) -> void:
	send_system_message(
		"[color=#" + color.to_html() + "]" + text + "[/color]"
	)
