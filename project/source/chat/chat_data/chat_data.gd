class_name ChatData
## Class responsible for the data found inside a chat box.
## It is separate from [ChatInterface] so that it can persist between scenes.

signal new_content_added(new_content: String)
signal changed()

var _content: Array[ChatMessage] = []

## Each [ChatMessage] is associated with one player from this list.
## Their position in the array determines their id (zero indexed).
var _players: Array[String] = []


## Returns all of the chat's content.
## It is a String formatted to be displayed in a RichTextLabel.
func all_content() -> String:
	var text: String = ""

	for chat_message in _content:
		if text != "":
			text += "\n"

		match chat_message.user_id:
			-2:
				text += chat_message.text
			-1:
				text += (
						"[color=#202020]System: [/color][color=#404040]"
						+ chat_message.text + "[/color]"
				)
			_:
				var username: String = _player_from_id(chat_message.user_id)
				text += (
						"[color=#202020]" + username
						+ ": [/color][color=#404040]"
						+ chat_message.text + "[/color]"
				)

	return text


## Clears all of the chat's content.
func clear() -> void:
	_content.clear()
	_players.clear()
	changed.emit()


func add_raw_message(text: String) -> void:
	_add_message(-2, text)


func add_system_message(text: String) -> void:
	_add_message(-1, text)


func add_human_message(username: String, text: String) -> void:
	var player_id: int = _players.find(username)
	if player_id == -1:
		player_id = _players.size()
		_players.append(username)

	_add_message(player_id, text)


func _add_message(user_id: int, text: String) -> void:
	var new_chat_message := ChatMessage.new()
	new_chat_message.user_id = user_id
	new_chat_message.text = text
	_content.append(new_chat_message)

	new_content_added.emit(text)
	changed.emit()


## Currently only returns the player's username.
func _player_from_id(id: int) -> String:
	if id >= 0 and id < _players.size():
		return _players[id]
	push_error("Invalid player id for chat data")
	return "???"
