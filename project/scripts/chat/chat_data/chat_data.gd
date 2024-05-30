class_name ChatData
## Class responsible for the data found inside a chat box.
## It is separate from [ChatInterface] so that it can persist between scenes.


signal new_content_added(new_content: String)
signal content_cleared()
signal loaded()

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


## Loads chat data from given Dictionary.
## Useful for saving/loading and for synchronizing.
func load_data(data: Dictionary) -> void:
	var parser := ChatDataFromDict.new()
	parser.parse(data)
	if parser.error:
		print_debug("Error while loading chat data: " + parser.error_message)
		return
	_content = parser.result_content
	_players = parser.result_players
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
