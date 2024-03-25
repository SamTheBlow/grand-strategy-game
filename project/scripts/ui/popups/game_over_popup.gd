class_name GameOverPopup
extends VBoxContainer


@export var winner_label: Label


## To be called when this node is created.
func init(winner: Country) -> void:
	winner_label.text = winner.country_name + " wins!"
