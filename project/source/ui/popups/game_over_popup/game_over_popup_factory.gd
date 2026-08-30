class_name GameOverPopupFactory
extends Node
## Opens the popup for when the game is over.

const _GAME_OVER_SCENE: PackedScene = preload("uid://cfhpg688geojo")

@export var popup_container: PopupContainer


func show_game_over(winning_country: Country) -> void:
	var popup := _GAME_OVER_SCENE.instantiate() as GameOverPopup
	popup.setup(winning_country)
	popup_container.add_popup(popup)
