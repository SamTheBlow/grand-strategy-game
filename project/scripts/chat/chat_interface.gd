class_name ChatInterface
extends Control
## Class responsible for a chat's interface.
## Displays a given chat data's contents.
## Emits a signal when the user submits input text.
##
## This script must be used in a scene that has the following nodes:
## - A RichTextLabel with the unique name "ChatText"
## - A LineEdit with the unique name "ChatInput"


signal input_submitted(input_text: String)


## The chat data associated with this chat box.
## Feel free to access, modify or overwrite it.
var chat_data: ChatData:
	set(value):
		if chat_data:
			chat_data.new_content_added.disconnect(
					_on_chat_data_new_content_added
			)
			chat_data.content_cleared.disconnect(_on_chat_data_content_cleared)
			chat_data.loaded.disconnect(_on_chat_data_loaded)
		
		chat_data = value
		
		chat_data.new_content_added.connect(
				_on_chat_data_new_content_added
		)
		chat_data.content_cleared.connect(_on_chat_data_content_cleared)
		chat_data.loaded.connect(_on_chat_data_loaded)
		
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


func _update_chat_log() -> void:
	if _chat_log:
		_chat_log.text = chat_data.all_content()


func _on_input_text_submitted(input_text: String) -> void:
	input_submitted.emit(input_text)
	
	# Clear the input field
	_chat_input.text = ""


func _on_chat_data_new_content_added(_new_content: String) -> void:
	_update_chat_log()


func _on_chat_data_content_cleared() -> void:
	_update_chat_log()


func _on_chat_data_loaded() -> void:
	_update_chat_log()
