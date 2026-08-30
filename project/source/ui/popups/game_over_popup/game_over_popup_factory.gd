class_name GameOverPopupFactory
extends Node
## Opens the [GameOverPopup] when the game is over.

const _GAME_OVER_SCENE: PackedScene = preload("uid://cfhpg688geojo")

@export var _game_node: GameNode
@export var _popup_container: PopupContainer


func _ready() -> void:
	_game_node.game.game_over.connect(_create_popup)


func _create_popup(winning_country: Country) -> void:
	var popup := _GAME_OVER_SCENE.instantiate() as GameOverPopup
	popup.setup(winning_country)
	_popup_container.add_popup(popup)
