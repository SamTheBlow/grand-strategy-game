class_name PlayingCountry
## Provides at any point in time
## the currently playing [Country] in some given [Game].
## Emits a signal when the country changes.

signal changed(country: Country)

var _game: Game

var _playing_country_id: int = -1:
	set(value):
		if _playing_country_id == value:
			return
		var country_before: Country = country()
		_playing_country_id = value
		var country_after: Country = country()
		if country_before != country_after:
			changed.emit(country_after)


func _init(game: Game) -> void:
	_game = game
	_update_country()
	_game.turn.is_running_changed.connect(_on_is_running_changed)
	_game.turn.player_changed.connect(_on_player_changed)


## May return null, in which case no country is currently playing.
func country() -> Country:
	return _game.countries.country_from_id(_playing_country_id)


func _update_country() -> void:
	if _game.turn.is_running():
		_playing_country_id = _game.turn.playing_player().playing_country.id
	else:
		_playing_country_id = -1


func _on_is_running_changed(_is_running: bool) -> void:
	_update_country()


func _on_player_changed(player: GamePlayer) -> void:
	_playing_country_id = player.playing_country.id
