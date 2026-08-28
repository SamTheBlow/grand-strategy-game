class_name ChatMessageParsing
## Parses raw data from/to a [ChatMessage].

const _USER_ID_KEY: String = "user_id"
const _TEXT_KEY: String = "text"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(raw_data: Variant) -> ChatMessage:
	var output := ChatMessage.new()

	if raw_data is not Dictionary:
		return output
	var raw_dict: Dictionary = raw_data

	if ParseUtils.dictionary_has_number(raw_dict, _USER_ID_KEY):
		var user_id: int = ParseUtils.dictionary_int(raw_dict, _USER_ID_KEY)
		# Ignore invalid ids instead of triggering the setter's warning.
		if user_id >= -2:
			output.user_id = user_id

	if ParseUtils.dictionary_has_string(raw_dict, _TEXT_KEY):
		output.text = raw_dict[_TEXT_KEY]

	return output


static func to_raw_dict(chat_message: ChatMessage) -> Dictionary:
	return {
		_USER_ID_KEY: chat_message.user_id,
		_TEXT_KEY: chat_message.text,
	}
