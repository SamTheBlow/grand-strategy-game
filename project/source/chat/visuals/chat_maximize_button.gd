extends Control
## The chat interface's maximize button.
## Appears when the chat is minimized.
## When its button is pressed, hides itself and shows the chat contents.

@export var chat_contents: Control


func _ready() -> void:
	hide()
	(%MaximizeButton as Button).pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	hide()
	chat_contents.show()
