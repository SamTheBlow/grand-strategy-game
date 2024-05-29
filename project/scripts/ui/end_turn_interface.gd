class_name EndTurnInterface
extends Control
## The interface allowing a player to end their turn.
## Typically contains a [Button] that says "End Turn".
## This class is responsible for hiding the interface when
## it is not the user's turn to play.


@export var _game: Game


func _ready() -> void:
	# DANGER safely accessing the [GameTurn] here relies on the fact
	# that everything is loaded before the [Game] enters the scene tree
	_update_visibility(_game.turn.playing_player())
	_game.turn.player_changed.connect(_on_turn_player_changed)


func _update_visibility(player: GamePlayer) -> void:
	visible = player and MultiplayerUtils.has_gameplay_authority(
			multiplayer, player
	)


func _on_turn_player_changed(player: GamePlayer) -> void:
	_update_visibility(player)
