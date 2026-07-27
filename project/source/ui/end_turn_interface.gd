class_name EndTurnInterface
extends Control
## Hides itself when it is not the user's turn to play.
##
## (Even though the class is named and intended for the "End Turn" button,
## this script has no functionality specific to it.)

@export var _game: GameNode


func _ready() -> void:
	_refresh()
	_game.game.game_started.connect(_refresh)
	_game.game.turn.playing_country_changed.connect(_refresh)


func _refresh(_country: Country = null) -> void:
	if not _game.game.turn.is_running():
		visible = false
		return

	var playing_players: Array[GamePlayer] = _game.game.turn.playing_players()
	if playing_players.is_empty():
		visible = false
		return

	var player: GamePlayer = playing_players[0]
	visible = MultiplayerUtils.has_gameplay_authority(multiplayer, player)
