class_name PopupButtons
extends HBoxContainer
## Class responsible for all of a [GamePopup]'s buttons.
## Creates buttons and adds them as children of this node.
## Emits a signal when one of the buttons is pressed,
## with the button's id as an argument.
##
## To use, call "setup_buttons" with a list of button names as the argument.

signal pressed(button_id: int)


## This is meant to be called only once.
func setup_buttons(button_names: Array[String]) -> void:
	for i in button_names.size():
		# Add space between each button
		if i > 0:
			var control := Control.new()
			control.name = "Spacing" + str(i)
			control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			control.mouse_filter = Control.MOUSE_FILTER_IGNORE
			add_child(control)

		var button := IdButton.new()
		button.name = "Button" + str(i + 1)
		button.id = i
		button.text = button_names[i]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.id_pressed.connect(_on_button_pressed)
		add_child(button)


func _on_button_pressed(id: int) -> void:
	pressed.emit(id)
