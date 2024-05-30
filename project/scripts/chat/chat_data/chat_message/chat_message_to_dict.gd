class_name ChatMessageToDict
## Converts a [ChatMessage] into raw data.
##
## See also: [ChatMessageFromDict]


func parse(chat_message: ChatMessage) -> Dictionary:
	return {
		"user_id": chat_message.user_id,
		"text": chat_message.text,
	}
