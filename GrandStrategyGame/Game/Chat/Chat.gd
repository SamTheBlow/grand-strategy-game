class_name Chat
extends Control


signal requested_province_info

@onready var chat_log: RichTextLabel = $ColorRect/MarginContainer/VBoxContainer/Log/MarginContainer/RichTextLabel as RichTextLabel
@onready var chat_input: LineEdit = $ColorRect/MarginContainer/VBoxContainer/Input as LineEdit


func _on_input_text_submitted(new_text: String):
	# Submit the message
	if new_text.begins_with("/"):
		# Commands
		match new_text:
			"/help":
				system_message_multiline([
					"/help - Gives a list of every command",
					"/test - Test command, has no effect",
					"/infop - Gives info on selected province",
					"/fs - Toggle fullscreen",
				])
			"/test":
				system_message("[b]Test successful[/b]")
			"/infop":
				emit_signal("requested_province_info")
			"/fs":
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


func system_message(new_text: String):
	chat_log.text += (
		"[i][color=#404040]"
		+ "System: " + new_text
		+ "[/color][/i]\n"
	)


func system_message_multiline(text_lines: Array[String]):
	var message: String = ""
	for text_line in text_lines:
		message += "\n" + text_line
	system_message(message)


func new_message(new_text: String):
	chat_log.text += new_text + "\n"
