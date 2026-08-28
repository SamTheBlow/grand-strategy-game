class_name ChatInterface
extends Control
## Class responsible for the chat's visuals and interactions with the user.
## Displays a given [ChatData]'s contents.
## Emits a signal when the user submits input text.
##
## This script must be used in a scene that has the following nodes:
## - A RichTextLabel with the unique name "ChatText"
## - A LineEdit with the unique name "ChatInput"

signal input_submitted(input_text: String)

## The data to be displayed in the chat box.
var chat_data: ChatData:
	set(value):
		if chat_data != null:
			chat_data.changed.disconnect(_refresh_contents)

		chat_data = value
		_refresh_contents()

		chat_data.changed.connect(_refresh_contents)

@onready var _chat_log := %ChatText as RichTextLabel
@onready var _chat_input := %ChatInput as LineEdit


func _init() -> void:
	# This is just so that it calls the setter.
	chat_data = ChatData.new()


func _ready() -> void:
	# Automatically connect the signal, in case it wasn't already done
	if not _chat_input.text_submitted.is_connected(_on_input_text_submitted):
		_chat_input.text_submitted.connect(_on_input_text_submitted)

	_refresh_contents()


func _refresh_contents() -> void:
	if not is_node_ready():
		return
	_chat_log.text = chat_data.all_content()


func _on_input_text_submitted(input_text: String) -> void:
	input_submitted.emit(input_text)

	# Clear the input field
	_chat_input.text = ""
