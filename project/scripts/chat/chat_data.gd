class_name ChatData
extends Node
## Class responsible for the data found inside a chat box.
## Useful for passing around between different chat interfaces.


signal new_content_added(new_content: String)
signal content_cleared()

var _text: String = ""


## Returns all of the chat's content.
## It is a String formatted to be displayed in a RichTextLabel.
func all_content() -> String:
	return _text


## Clears all of the chat's content.
func clear() -> void:
	_text = ""
	content_cleared.emit()


## Appends a newline character to the previous added content,
## then adds the given String as new content.
func add_content(new_content: String) -> void:
	if _text != "":
		_text += "\n"
	_text += new_content
	new_content_added.emit(new_content)
