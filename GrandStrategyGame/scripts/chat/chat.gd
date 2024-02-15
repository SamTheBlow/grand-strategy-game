class_name Chat
extends Control


signal save_requested()
signal load_requested()
signal exit_to_main_menu_requested()
signal rules_requested()

@onready var chat_log := %ChatText as RichTextLabel
@onready var chat_input := %ChatInput as LineEdit


func _ready() -> void:
	send_global_message("The game begins!")
	send_global_message("Type /help to get a list of commands.")


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
				system_message_multiline([
						"/help - Get a list of every command",
						"/fs - Toggle fullscreen",
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
					system_message("Switched to windowed")
				else:
					DisplayServer.window_set_mode(
							DisplayServer.WINDOW_MODE_FULLSCREEN
					)
					system_message("Switched to fullscreen")
			"save":
				system_message("Saving the game...")
				save_requested.emit()
			"load":
				system_message("Loading the save file...")
				load_requested.emit()
			"mainmenu":
				exit_to_main_menu_requested.emit()
			"rules":
				rules_requested.emit()
			_:
				system_message(
						'"[color=black]' + new_text + '[/color]"'
						+ " is not a valid command"
				)
	else:
		# Not a command
		new_message(new_text)
	
	# Clear the input field
	chat_input.text = ""


## Sends a message to all players.
func send_global_message(text: String) -> void:
	chat_log.text += "[i][color=#404040]" + text + "[/color][/i]\n"


# TODO don't send to all players (when multiplayer is implemented)
## Sends a private message to the player.
func system_message(new_text: String) -> void:
	chat_log.text += (
			"[color=#202020]System: [/color][color=#404040]"
			+ new_text + "[/color]\n"
	)


func system_message_multiline(text_lines: Array[String]) -> void:
	var message: String = ""
	for text_line in text_lines:
		message += "\n" + text_line
	system_message(message)


func new_message(new_text: String) -> void:
	var stripped_text: String = new_text.strip_edges()
	
	if stripped_text == "":
		return
	
	chat_log.text += (
			"[color=#202020]You: [/color][color=#404040]"
			+ stripped_text + "[/color]\n"
	)
