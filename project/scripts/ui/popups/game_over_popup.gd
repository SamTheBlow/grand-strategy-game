class_name GameOverPopup
extends VBoxContainer
## Contents for the popup that appears when the game is over.
##
## See [GamePopup] to learn more on how popups work.


@export var winner_label: Label


## To be called when this node is created.
func init(winner: Country) -> void:
	winner_label.text = winner.country_name + " wins!"
