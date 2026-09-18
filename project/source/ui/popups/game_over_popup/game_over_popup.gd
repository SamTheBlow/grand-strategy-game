class_name GameOverPopup
extends VBoxContainer
## Shows who won, if applicable.
## Allows the user to either quit the game or continue playing.
##
## See also: [GamePopup]

signal quit_requested()

const _QUIT_BUTTON_ID: int = 0

@export var _winner_label: Label


func setup(country: Country) -> void:
	if country == null:
		_winner_label.text = "Game Over!"
	else:
		_winner_label.text = country.name_or_default() + " wins!"


func buttons() -> Array[String]:
	return ["Quit", "Keep Playing"]


func _on_button_pressed(button_id: int) -> void:
	if button_id == _QUIT_BUTTON_ID:
		quit_requested.emit()
