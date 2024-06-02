class_name AutoEndTurn
## Automatically ends a [GamePlayer]'s turn when they are turned into an AI.
##
## See also: [GameTurn]


var _turn: GameTurn

var _human_status_changed: Signal:
	set(value):
		if _human_status_changed:
			_human_status_changed.disconnect(_on_player_human_status_changed)
		_human_status_changed = value
		_human_status_changed.connect(_on_player_human_status_changed)


func _init(game: Game) -> void:
	_turn = game.turn
	_turn.player_changed.connect(_on_turn_player_changed)
	game.game_started.connect(_on_game_started)


func _on_game_started() -> void:
	_human_status_changed = _turn.playing_player().human_status_changed


func _on_turn_player_changed(player: GamePlayer) -> void:
	_human_status_changed = player.human_status_changed


func _on_player_human_status_changed(player: GamePlayer) -> void:
	if not player.is_human:
		_turn.end_turn()
