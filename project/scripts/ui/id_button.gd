class_name IdButton
extends Button
## This button has an id given by some other node.
## When pressed, this button emits a custom signal
## that contains the button's id as an argument.
## Useful for being able to know which button
## was pressed among some group of buttons.


signal id_pressed(id: int)

var id: int = 0


func _ready() -> void:
	pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	id_pressed.emit(id)
