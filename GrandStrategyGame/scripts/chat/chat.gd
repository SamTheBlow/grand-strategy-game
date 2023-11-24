class_name Chat
extends Control


signal requested_province_info()
signal save_requested()
signal load_requested()
signal exit_to_main_menu_requested()
signal rules_requested()

@onready var chat_log := %ChatText as RichTextLabel
@onready var chat_input := %ChatInput as LineEdit


func _on_input_text_submitted(new_text: String) -> void:
	# Submit the message
	if new_text.begins_with("/"):
		# Commands
		match new_text.trim_prefix("/"):
			"help":
				system_message_multiline([
						"/help - Gives a list of every command",
						"/infop - Gives info on selected province",
						"/fs - Toggle fullscreen",
						"/save - Save the current game state",
						"/load - Load the saved game state",
						"/mainmenu - Go back to the main menu (without saving!)",
						"/rules - Gives a list of the current game rules",
				])
			"infop":
				requested_province_info.emit()
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
						+ "is not a valid command"
				)
	else:
		# Not a command
		new_message(new_text)
	
	# Clear the input field
	chat_input.text = ""


func system_message(new_text: String) -> void:
	chat_log.text += (
			"[i][color=#404040]" + "System: " + new_text + "[/color][/i]\n"
	)


func system_message_multiline(text_lines: Array[String]) -> void:
	var message: String = ""
	for text_line in text_lines:
		message += "\n" + text_line
	system_message(message)


func new_message(new_text: String) -> void:
	chat_log.text += new_text + "\n"
