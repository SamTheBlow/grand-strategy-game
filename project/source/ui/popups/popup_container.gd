class_name PopupContainer
extends Control
## Creates popups that may appear during a game.
##
## See also: [GamePopup]

const _POPUP_SCENE: PackedScene = preload("uid://by865efl4iwy")
const _COUNTRY_INFO_SCENE: PackedScene = preload("uid://2hy14ir4o0ps")

@export var _game_node: GameNode


func add_popup(contents: Node) -> void:
	var popup := _POPUP_SCENE.instantiate() as GamePopup
	popup.contents_node = contents
	add_child(popup)


## Opens a popup with information about given country.
func show_country_info(country: Country) -> void:
	var country_info := _COUNTRY_INFO_SCENE.instantiate() as CountryInfoPopup
	country_info.setup(_game_node.game, country)
	country_info.diplomacy_action_requested.connect(
			_game_node.request_diplomacy_action
	)
	add_popup(country_info)
