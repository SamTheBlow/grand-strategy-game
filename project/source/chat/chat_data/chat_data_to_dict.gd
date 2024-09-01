class_name ChatDataToDict
## Converts a [ChatData] into raw data.
##
## See also: [ChatDataFromDict]


func parse(chat_data: ChatData) -> Dictionary:
	var content: Array[Dictionary] = []
	for chat_message in chat_data._content:
		content.append(ChatMessageToDict.new().parse(chat_message))
	
	return {
		ChatDataFromDict.CONTENT_KEY: content,
		ChatDataFromDict.PLAYERS_KEY: chat_data._players,
	}
