class_name CountryInfoPopupFactory
extends Node
## Opens a popup with information about some given country.

const _COUNTRY_INFO_SCENE: PackedScene = preload("uid://2hy14ir4o0ps")

@export var game_node: GameNode
@export var popup_container: PopupContainer


func show_country_info(country: Country) -> void:
	var popup := _COUNTRY_INFO_SCENE.instantiate() as CountryInfoPopup
	popup.setup(game_node.game, country)
	popup.diplomacy_action_requested.connect(
			game_node.confirm_diplomacy_action
	)
	popup_container.add_popup(popup)
