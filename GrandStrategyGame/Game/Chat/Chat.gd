extends Control

signal requested_province_info

@onready var chat_log:RichTextLabel = $ColorRect/MarginContainer/VBoxContainer/Log/MarginContainer/RichTextLabel
@onready var chat_input:LineEdit = $ColorRect/MarginContainer/VBoxContainer/Input

func _on_input_text_submitted(new_text:String):
	# Submit the message
	if new_text.begins_with("/"):
		# Commands
		match new_text:
			"/help":
				system_message( \
				"\n" + \
				"/help - Gives a list of every command\n" + \
				"/test - Test command, has no effect\n" + \
				"/infop - Gives info on selected province\n" + \
				"/fs - Toggle fullscreen")
			"/test":
				system_message("[b]Test successful[/b]")
			"/infop":
				emit_signal("requested_province_info")
			"/fs":
				var mode = DisplayServer.window_get_mode()
				if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
					system_message("Switched to windowed")
				else:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
					system_message("Switched to fullscreen")
			_:
				system_message('"[color=black]' + new_text + '[/color]" is not a valid command')
	else:
		# Not a command
		new_message(new_text)
	
	# Clear the input field
	chat_input.text = ""

func system_message(new_text:String):
	chat_log.text += "[i][color=#404040]"
	chat_log.text += "System: "
	chat_log.text += new_text + "[/color][/i]\n"

func new_message(new_text:String):
	chat_log.text += new_text + "\n"
