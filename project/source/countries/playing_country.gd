class_name PlayingCountry
## Contains a [Country] that may change arbitrarily.
## Emits a signal when the country changes.

signal changed(country: Country)

var _turn: GameTurn

var _country: Country:
	set(value):
		if _country == value:
			return
		_country = value
		changed.emit(_country)


func _init(turn: GameTurn) -> void:
	_turn = turn
	_update_country()
	turn.is_running_changed.connect(_on_is_running_changed)
	turn.player_changed.connect(_on_player_changed)


## May return null.
func country() -> Country:
	return _country


func _update_country() -> void:
	if _turn.is_running():
		_country = _turn.playing_player().playing_country
	else:
		_country = null


func _on_is_running_changed(_is_running: bool) -> void:
	_update_country()


func _on_player_changed(player: GamePlayer) -> void:
	_country = player.playing_country
