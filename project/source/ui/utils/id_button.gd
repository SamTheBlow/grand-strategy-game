class_name IdButton
extends Button
## Has a given id. When pressed, emits a signal with the id as argument.
## Useful for being able to know which button
## was pressed among some group of buttons.

signal id_pressed(id: int)

@export var id: int = 0


func _ready() -> void:
	pressed.connect(_on_button_pressed)


func _on_button_pressed() -> void:
	id_pressed.emit(id)
