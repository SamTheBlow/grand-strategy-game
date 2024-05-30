class_name ChatMessageFromDict
## Converts raw data into a [ChatMessage].
##
## See also: [ChatMessageToDict]


var error: bool = false
var error_message: String = ""
var result: ChatMessage = null


func parse(dict: Dictionary) -> void:
	error = false
	error_message = ""
	result = null
	
	var chat_message := ChatMessage.new()
	if dict.has("user_id"):
		if dict["user_id"] is int:
			var id := dict["user_id"] as int
			if id < -2:
				error = true
				error_message = "User id is invalid."
				return
			# Note that you still need to verify that the id
			# refers to a valid player in the chat data's player list
			chat_message.user_id = id
		else:
			print_debug("Chat message player id is not an int.")
	if dict.has("text"):
		if dict["text"] is String:
			var text := dict["text"] as String
			chat_message.text = text
		else:
			print_debug("Chat message text data is not a string.")
	
	result = chat_message
