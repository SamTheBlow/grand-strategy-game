extends Control
## The chat interface's minimize button.
## This button is visible whenever the chat itself is visible.
## When its button is pressed, hides the chat and shows the maximize button.


@export var chat_contents: Control
@export var maximize_button: Control


func _ready() -> void:
	(%MinimizeButton as Button).pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	chat_contents.hide()
	maximize_button.show()
