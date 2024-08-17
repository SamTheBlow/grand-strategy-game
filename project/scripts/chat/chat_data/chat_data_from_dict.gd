class_name ChatDataFromDict
## Converts raw data into [ChatData] data.
## Gives a human-friendly error message when it fails.
##
## See also: [ChatDataToDict]


var error: bool = false
var error_message: String = ""
var result_content: Array[ChatMessage] = []
var result_players: Array[String] = []


func parse(data: Dictionary) -> void:
	error = false
	error_message = ""
	result_content = []
	result_players = []
	
	var players: Array[String] = []
	if data.has("players"):
		players = _parse_players(data["players"])
	
	var content: Array[ChatMessage] = []
	if data.has("content"):
		content = _parse_content(data["content"], players.size())
		if error:
			return
	
	# Success
	result_content = content
	result_players = players


## Returns null if an error occured.
## The content data will not be valid if...
## - [ChatMessageFromDict] fails to parse the data.
## - One of the content's player ids is invalid
##   (i.e. it doesn't redirect to a player from the players array).
func _parse_content(
		content_data: Variant, players_size: int
) -> Array[ChatMessage]:
	if content_data is not Array:
		push_warning("Chat content data is not an Array.")
		return []
	var content_array := content_data as Array
	
	var content: Array[ChatMessage] = []
	for chat_message_data: Variant in content_array:
		if not (chat_message_data is Dictionary):
			push_warning("Chat message data is not a Dictionary.")
			continue
		var chat_message_dict := chat_message_data as Dictionary
		
		var parser := ChatMessageFromDict.new()
		parser.parse(chat_message_dict)
		if parser.error:
			error = true
			error_message = parser.error_message
			return []
		
		var chat_message: ChatMessage = parser.result
		if chat_message.user_id >= players_size:
			error = true
			error_message = "Invalid player id in one of the messages."
			return []
		
		content.append(chat_message)
	return content


## The player data will always be valid since it's just strings.
## Just ignore anything that isn't a string.
func _parse_players(players_data: Variant) -> Array[String]:
	if not (players_data is Array):
		push_warning("Chat players data is not an Array.")
		return []
	var players_array := players_data as Array
	
	var players: Array[String] = []
	for player_data: Variant in players_array:
			if not (player_data is String):
				push_warning("Chat player data is not a String.")
				continue
			var player_string := player_data as String
			players.append(player_string)
	return players
