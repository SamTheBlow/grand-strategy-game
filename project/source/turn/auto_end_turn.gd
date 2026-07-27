class_name AutoEndTurn
## Automatically ends a [GamePlayer]'s turn when they are turned into an AI.
##
## See also: [GameTurn]

var _turn: GameTurn

var _human_status_changed: Signal

func _init(game: Game) -> void:
	_turn = game.turn
	_turn.playing_country_changed.connect(_update_signal)
	game.game_started.connect(_update_signal)


func _update_signal(_country: Country = null) -> void:
	if _human_status_changed:
		_human_status_changed.disconnect(_on_player_human_status_changed)

	var playing_players: Array[GamePlayer] = _turn.playing_players()
	if playing_players.is_empty():
		return
	var playing_player: GamePlayer = playing_players[0]

	_human_status_changed = playing_player.human_status_changed
	_human_status_changed.connect(_on_player_human_status_changed)


func _on_player_human_status_changed(player: GamePlayer) -> void:
	if not player.is_human:
		_turn.start()
