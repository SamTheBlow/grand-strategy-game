class_name EndTurnInterface
extends Control
## Hides itself when it is not the user's turn to play.
##
## (Even though the class is named and intended for the "End Turn" button,
## this script has no functionality specific to it.)

@export var _game: GameNode


func _ready() -> void:
	visible = false
	_game.game.game_started.connect(_on_game_started)
	_game.game.turn.player_changed.connect(_on_turn_player_changed)


func _update_visibility(player: GamePlayer) -> void:
	visible = (
			player != null
			and MultiplayerUtils.has_gameplay_authority(multiplayer, player)
	)


func _on_game_started() -> void:
	_update_visibility(_game.game.turn.playing_player())


func _on_turn_player_changed(player: GamePlayer) -> void:
	_update_visibility(player)
