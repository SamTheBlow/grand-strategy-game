class_name CountryInfoPopupFactory
extends Node

signal action_requested(action: Action)

const _COUNTRY_INFO_SCENE: PackedScene = preload("uid://2hy14ir4o0ps")

@export var _game_node: GameNode
@export var _popup_container: PopupContainer


## Opens a popup with information about some given country.
func show_country_info(country: Country) -> void:
	var popup := _COUNTRY_INFO_SCENE.instantiate() as CountryInfoPopup
	popup.setup(_game_node.game, country)
	popup.diplomacy_action_requested.connect(confirm_diplomacy_action)
	_popup_container.add_popup(popup)


## Requests applying a diplomacy action.
func confirm_diplomacy_action(
		diplomacy_action: DiplomacyAction, recipient_country: Country
) -> void:
	if not _game_node.game.turn.is_running():
		return

	# TODO this check shouldn't be here...
	if not MultiplayerUtils.has_gameplay_authority(
			_game_node.multiplayer, _game_node.game.turn.playing_players()[0]
	):
		push_warning(
				"Tried to perform a diplomatic action, but"
				+ " the user does not have gameplay authority!"
		)
		return

	action_requested.emit(
			ActionDiplomacy.new(diplomacy_action.id(), recipient_country.id)
	)
