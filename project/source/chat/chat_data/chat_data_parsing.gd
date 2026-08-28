class_name ChatDataParsing
## Parses raw data from/to a [ChatData].

const _CONTENT_KEY: String = "content"
const _PLAYERS_KEY: String = "players"


## Loads given instance using given raw data.
## Clears existing contents.
static func load_from_raw_data(raw_data: Variant, chat_data: ChatData) -> void:
	chat_data._content = []
	chat_data._players = []

	if raw_data is not Dictionary:
		chat_data.changed.emit()
		return
	var raw_dict := raw_data as Dictionary

	if ParseUtils.dictionary_has_array(raw_dict, _PLAYERS_KEY):
		chat_data._players = _players_from_raw_data(raw_dict[_PLAYERS_KEY])

	if ParseUtils.dictionary_has_array(raw_data, _CONTENT_KEY):
		chat_data._content = _content_from_raw_data(
				raw_data[_CONTENT_KEY], chat_data._players.size()
		)

	chat_data.changed.emit()


## Discards anything that isn't a string.
static func _players_from_raw_data(raw_array: Array) -> Array[String]:
	var output: Array[String] = []

	for player_raw_data: Variant in raw_array:
		if player_raw_data is String:
			output.append(player_raw_data)

	return output


## Discards any message that isn't a valid dictionary,
## or that refers to an invalid player id.
static func _content_from_raw_data(
		raw_array: Variant, players_size: int
) -> Array[ChatMessage]:
	var output: Array[ChatMessage] = []

	for chat_message_raw_data: Variant in raw_array:
		if chat_message_raw_data is not Dictionary:
			continue

		var chat_message: ChatMessage = (
				ChatMessageParsing.from_raw_data(chat_message_raw_data)
		)
		if chat_message.user_id >= players_size:
			continue

		output.append(chat_message)

	return output


static func to_raw_dict(chat_data: ChatData) -> Dictionary:
	var content: Array[Dictionary] = []
	for chat_message in chat_data._content:
		content.append(ChatMessageParsing.to_raw_dict(chat_message))

	return {
		_CONTENT_KEY: content,
		_PLAYERS_KEY: chat_data._players,
	}
