class_name GameOverPopup
extends VBoxContainer
## Message that appears when the game is over.
##
## See also: [GamePopup]

@export var winner_label: Label


func setup(country: Country) -> void:
	if country == null:
		winner_label.text = "Game Over!"
	else:
		winner_label.text = country.name_or_default() + " wins!"
