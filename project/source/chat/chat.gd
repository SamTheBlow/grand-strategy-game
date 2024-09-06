class_name Chat
extends Node
## Class responsible for communication between the different components
## of the chat, namely the [ChatData] and the [ChatInterface].
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
## class, not the functions from [ChatData].


signal save_requested()
signal load_requested()
signal exit_to_main_menu_requested()
signal rules_requested()

@export var players: Players

var chat_data := ChatData.new()


func _ready() -> void:
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	
	if players:
		players.player_kicked.connect(_on_players_player_kicked)
		players.player_group_added.connect(_on_players_player_group_added)
		players.player_group_removed.connect(_on_players_player_group_removed)


## Call this to listen to a chat interface's inputs.
func connect_chat_interface(chat_interface: ChatInterface) -> void:
	chat_interface.input_submitted.connect(_on_chat_interface_input_submitted)


#region Send all data
## Sends all chat data to whoever requests it.
@rpc("any_peer", "call_remote", "reliable")
func _send_all_data() -> void:
	if not MultiplayerUtils.is_server(multiplayer):
		push_warning(
				"Received a request to send all data, "
				+ "but you are not the server!"
		)
		return
	
	_receive_all_data.rpc_id(
			multiplayer.get_remote_sender_id(),
			ChatDataToDict.new().parse(chat_data)
	)


## The user who requested all chat data receives it.
@rpc("authority", "call_remote", "reliable")
func _receive_all_data(chat_data_dict: Dictionary) -> void:
	chat_data.load_data(chat_data_dict)
#endregion


#region Send global message
## Sends a message to all users. Clients are not allowed to call this.
func send_global_message(text: String) -> void:
	if not MultiplayerUtils.has_authority(multiplayer):
		push_warning(
				"Tried to send a global message, "
				+ "but you do not have authority!"
		)
		return
	
	if MultiplayerUtils.is_online(multiplayer):
		_receive_global_message.rpc(text)
	else:
		_receive_global_message(text)


@rpc("any_peer", "call_local", "reliable")
func _receive_global_message(text: String) -> void:
	if (
			MultiplayerUtils.is_online(multiplayer)
			and multiplayer.get_remote_sender_id() != 1
	):
		# The user who sent this does not have authority.
		# Probably a hacker? Anyways, deny them permission.
		push_warning(
				"Received a global message from someone "
				+ "who does not have authority!"
		)
		return
	
	chat_data.add_raw_message("[i][color=#404040]" + text + "[/color][/i]")
#endregion


#region Send human message
## Sends to all users a message written by the local user.
func send_human_message(text: String) -> void:
	var username: String = players.you().username()
	
	if MultiplayerUtils.is_online(multiplayer):
		_receive_human_message.rpc(username, text)
	else:
		_receive_human_message(username, text)


@rpc("any_peer", "call_local", "reliable")
func _receive_human_message(username: String, text: String) -> void:
	var stripped_text: String = text.strip_edges()
	if stripped_text == "":
		return
	
	chat_data.add_human_message(username, stripped_text)
#endregion


## Sends a private message to the user.
func send_system_message(text: String) -> void:
	chat_data.add_system_message(text)


## Utility function to send a system message with multiple lines.
func send_system_message_multiline(text_lines: Array[String]) -> void:
	var message: String = ""
	for text_line in text_lines:
		message += "\n" + text_line
	send_system_message(message)


## Upon connecting to a server, clients immediately request the
## server's chat data, for synchronization.
func _on_connected_to_server() -> void:
	if multiplayer.is_server():
		return
	_send_all_data.rpc_id(1)


func _on_players_player_kicked(player: Player) -> void:
	send_global_message(player.username() + " was kicked from the server.")


func _on_players_player_group_added(leader: Player) -> void:
	send_global_message(leader.username() + " joined the server.")


func _on_players_player_group_removed(leader: Player) -> void:
	send_global_message(leader.username() + " left the server.")


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
						"/about - Get the game version",
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
			"about":
				send_system_message("Current version: " + str(
						ProjectSettings.get_setting_with_override(
								"application/config/version"
						)
				))
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
