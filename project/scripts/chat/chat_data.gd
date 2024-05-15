class_name ChatData
## Class responsible for the data found inside a chat box.
## Useful for passing around between different chat interfaces.
##
## When storing info about users, each user is assigned a unique id.
## System messages use the id -1, and raw messages use -2.
# TODO mark all messages with the time they were sent
# TODO sort messages chronologically
# TODO when connecting to server, don't overwrite previous chat contents
# TODO when connecting to server, don't receive the host's private messages


signal new_content_added(new_content: String)
signal content_cleared()
signal loaded()

var _content: Array[ChatMessage] = []

## Their position in the array determines their id (zero indexed)
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
				text += (
						"[i][color=#404040]"
						+ chat_message.text + "[/color][/i]"
				)
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


## Returns all of this object's data as a Dictionary.
## Useful for saving/loading and for synchronizing.
func all_data() -> Dictionary:
	var content: Array[Dictionary] = []
	for chat_message in _content:
		content.append(chat_message.to_dictionary())
	
	return {
		"content": content,
		"players": _players,
	}


# TODO this is prone to crashing due to corrupted data
## Loads chat data from given Dictionary.
## Useful for saving/loading and for synchronizing.
func load_data(data: Dictionary) -> void:
	if data.has("content"):
		_content = []
		for chat_message_dict: Dictionary in data["content"]:
			_content.append(ChatMessage.from_dictionary(chat_message_dict))
	if data.has("players"):
		_players = []
		for player: String in data["players"]:
			_players.append(player)
	
	loaded.emit()


## Clears all of the chat's content.
func clear() -> void:
	_content = []
	_players = []
	content_cleared.emit()


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


## Currently only returns the player's username.
func _player_from_id(id: int) -> String:
	if id >= 0 and id < _players.size():
		return _players[id]
	print_debug("Invalid player id for chat data")
	return "???"


class ChatMessage:
	## -2 is raw message, -1 is system message, 0+ is user message
	var user_id: int = -2
	var text: String = ""
	
	
	func to_dictionary() -> Dictionary:
		return {
			"user_id": user_id,
			"text": text,
		}
	
	
	# TODO prone to crashing due to corrupted data
	static func from_dictionary(dictionary: Dictionary) -> ChatMessage:
		var chat_message := ChatMessage.new()
		if dictionary.has("user_id"):
			chat_message.user_id = dictionary["user_id"]
		if dictionary.has("text"):
			chat_message.text = dictionary["text"]
		return chat_message
