class_name PlayingCountry
## Provides at any point in time
## the currently playing [Country] in some given [Game].
## Emits a signal when the country changes.

signal changed(country: Country)

var _game: Game

## May be null.
var _playing_country: Country = null:
	set(value):
		if _playing_country == value:
			return
		_playing_country = value
		changed.emit(_playing_country)


func _init(game: Game) -> void:
	_game = game
	_update_country()
	_game.turn.is_running_changed.connect(_on_is_running_changed)
	_game.turn.playing_country_changed.connect(_on_playing_country_changed)


## May return null, in which case no country is currently playing.
func country() -> Country:
	return _playing_country


func _update_country() -> void:
	if _game.turn.is_running():
		_playing_country = _game.turn.playing_country()
	else:
		_playing_country = null


func _on_is_running_changed(_is_running: bool) -> void:
	_update_country()


func _on_playing_country_changed(playing_country: Country) -> void:
	_playing_country = playing_country
