class_name ChatMessage
## Data structure for one message in the [ChatData].


## -2 is raw message, -1 is system message, 0+ is user message
var user_id: int = -2:
	set(value):
		if value < -2:
			push_warning("Tried to set user id to invalid value.")
			user_id = -2
			return
		
		user_id = value

var text: String = ""
