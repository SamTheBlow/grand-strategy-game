class_name ChatMessageFromDict
## Converts raw data into a [ChatMessage].
##
## See also: [ChatMessageToDict]


const USER_ID_KEY: String = "user_id"
const TEXT_KEY: String = "text"

var error: bool = false
var error_message: String = ""
var result: ChatMessage = null


func parse(dict: Dictionary) -> void:
	error = false
	error_message = ""
	result = null
	
	var chat_message := ChatMessage.new()
	
	if dict.has(USER_ID_KEY):
		if dict[USER_ID_KEY] is int:
			var id := dict[USER_ID_KEY] as int
			if id < -2:
				error = true
				error_message = "User id is invalid."
				return
			# Note that you still need to verify that the id
			# refers to a valid player in the chat data's player list
			chat_message.user_id = id
		else:
			push_warning("Chat message player id is not an int.")
	
	if dict.has(TEXT_KEY):
		if dict[TEXT_KEY] is String:
			var text := dict[TEXT_KEY] as String
			chat_message.text = text
		else:
			push_warning("Chat message text data is not a string.")
	
	result = chat_message
