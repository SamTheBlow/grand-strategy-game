class_name ChatMessageToDict
## Converts a [ChatMessage] into raw data.
##
## See also: [ChatMessageFromDict]


func parse(chat_message: ChatMessage) -> Dictionary:
	return {
		ChatMessageFromDict.USER_ID_KEY: chat_message.user_id,
		ChatMessageFromDict.TEXT_KEY: chat_message.text,
	}
