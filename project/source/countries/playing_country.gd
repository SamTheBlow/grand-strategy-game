class_name PlayingCountry
## Contains a [Country] that may change arbitrarily.
## Emits a signal when the country changes.


signal changed(country: Country)

var _country: Country


func _init(turn: GameTurn = null) -> void:
	if turn == null:
		return
	
	_country = turn.playing_player().playing_country
	turn.player_changed.connect(_on_player_changed)


## May return null.
func country() -> Country:
	return _country


func _on_player_changed(player: GamePlayer) -> void:
	if player.playing_country != _country:
		_country = player.playing_country
		changed.emit(_country)
