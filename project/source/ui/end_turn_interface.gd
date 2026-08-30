class_name EndTurnInterface
extends Control
## Emits a signal with an [ActionEndTurn] when user wants to end their turn.
## Hides itself when it is not the user's turn to play.

signal action_requested(action: Action)

@export var _game_node: GameNode


func _ready() -> void:
	_refresh()
	_game_node.game.turn.is_running_changed.connect(_refresh.unbind(1))
	_game_node.game.turn.playing_country_changed.connect(_refresh.unbind(1))


func end_turn() -> void:
	action_requested.emit(ActionEndTurn.new())


func _refresh() -> void:
	if not _game_node.game.turn.is_running():
		visible = false
		return

	var playing_players: Array[GamePlayer] = (
			_game_node.game.turn.playing_players()
	)
	if playing_players.is_empty():
		visible = false
		return

	var player: GamePlayer = playing_players[0]
	visible = MultiplayerUtils.has_gameplay_authority(multiplayer, player)
