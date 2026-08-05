@abstract class_name ArrowBehavior
## Determines which country's auto-arrows are visible and editable.


@abstract func start(
		_input: AutoArrowInput, _container: AutoArrowContainer
) -> void


## Disconnects everything connected by start().
func stop() -> void:
	pass


## Shows the playing country's arrows, only while a province is selected.
class ShowPlayingCountry extends ArrowBehavior:
	var _game: Game
	var _multiplayer: MultiplayerAPI
	var _province_selection: ProvinceSelection
	var _playing_country: PlayingCountry

	var _input: AutoArrowInput
	var _container: AutoArrowContainer

	func _init(
			game: Game,
			multiplayer: MultiplayerAPI,
			province_selection: ProvinceSelection,
			playing_country: PlayingCountry
	) -> void:
		_game = game
		_multiplayer = multiplayer
		_province_selection = province_selection
		_playing_country = playing_country

	func start(
			input: AutoArrowInput, container: AutoArrowContainer
	) -> void:
		_input = input
		_container = container

		# Initialize
		_update_visibility(_province_selection.selected_province)
		_update_country()

		# Connect signals for automatic updates
		_province_selection.selected_province_changed.connect(
				_update_visibility
		)
		_playing_country.changed.connect(_update_country.unbind(1))

	func stop() -> void:
		_province_selection.selected_province_changed.disconnect(
				_update_visibility
		)
		_playing_country.changed.disconnect(_update_country)

	func _update_visibility(selected_province: Province) -> void:
		_container.visible = selected_province != null

	func _update_country() -> void:
		var country_id: int = _current_country_id()
		_input.country_to_edit_id = country_id
		_container.show_country(country_id)

	## Returns the playing country's id only when you control it.
	func _current_country_id() -> int:
		if not _game.turn.is_running():
			return -1

		if _game.game_players.you_control_country(
				_multiplayer, _playing_country.country()
		):
			return _playing_country.country().id

		return -1


## Shows the arrows of a given country, regardless of gameplay.
class ShowSpecificCountry extends ArrowBehavior:
	var _country_id: int

	func _init(country_id: int) -> void:
		_country_id = country_id

	func start(input: AutoArrowInput, container: AutoArrowContainer) -> void:
		input.country_to_edit_id = _country_id
		container.show()
		container.show_country(_country_id)
