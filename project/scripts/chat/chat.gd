class_name Chat
extends Control
## Class responsible for a visible & interactable chat interface.
## Displays and updates chat data. Listens and responds to user input.
## Emits certain signals when certain chat commands are called by the user.
##
## This script must be used in a scene that has the following nodes:
## - A RichTextLabel with the unique name "ChatText"
## - A LineEdit with the unique name "ChatInput"


signal save_requested()
signal load_requested()
signal exit_to_main_menu_requested()
signal rules_requested()

## The chat data associated with this chat box.
## Feel free to access, modify or overwrite it.
var chat_data: ChatData:
	set(value):
		if chat_data:
			chat_data.new_content_added.disconnect(
					_on_chat_data_new_content_added
			)
			chat_data.content_cleared.disconnect(_on_chat_data_content_cleared)
		
		chat_data = value
		
		chat_data.new_content_added.connect(
				_on_chat_data_new_content_added
		)
		chat_data.content_cleared.connect(_on_chat_data_content_cleared)
		
		_update_chat_log()

@onready var _chat_log := %ChatText as RichTextLabel
@onready var _chat_input := %ChatInput as LineEdit


func _init() -> void:
	# This is just so that it calls the setter.
	chat_data = ChatData.new()


func _ready() -> void:
	# Automatically connect the signal, in case it wasn't already done
	if not _chat_input.text_submitted.is_connected(_on_input_text_submitted):
		_chat_input.text_submitted.connect(_on_input_text_submitted)
	
	_update_chat_log()


## Sends a message to all players.
func send_global_message(text: String) -> void:
	chat_data.add_content("[i][color=#404040]" + text + "[/color][/i]")


# TODO don't send to all players (when multiplayer is implemented)
## Sends a private message to the player.
func send_system_message(new_text: String) -> void:
	chat_data.add_content(
			"[color=#202020]System: [/color][color=#404040]"
			+ new_text + "[/color]"
	)


func send_system_message_multiline(text_lines: Array[String]) -> void:
	var message: String = ""
	for text_line in text_lines:
		message += "\n" + text_line
	send_system_message(message)


## Sends to all players a message written by the player.
func send_human_message(new_text: String) -> void:
	var stripped_text: String = new_text.strip_edges()
	
	if stripped_text == "":
		return
	
	chat_data.add_content(
			"[color=#202020]You: [/color][color=#404040]"
			+ stripped_text + "[/color]"
	)


func _update_chat_log() -> void:
	if _chat_log:
		_chat_log.text = chat_data.all_content()


func _on_input_text_submitted(new_text: String) -> void:
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
	
	# Clear the input field
	_chat_input.text = ""


func _on_networking_interface_message_sent(text: String, color: Color) -> void:
	send_system_message(
		"[color=#" + color.to_html() + "]" + text + "[/color]"
	)


func _on_chat_data_new_content_added(_new_content: String) -> void:
	_update_chat_log()


func _on_chat_data_content_cleared() -> void:
	_update_chat_log()
