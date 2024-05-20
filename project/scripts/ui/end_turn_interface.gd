class_name EndTurnInterface
extends Control
## Class responsible for the interface allowing a player to end their turn.


@export var _game: Game


func _ready() -> void:
	# TODO bad code, don't use another class' private properties
	_update_visibility(_game._you)
	_game.turn.player_changed.connect(_on_turn_player_changed)


func _update_visibility(player: GamePlayer) -> void:
	visible = player and MultiplayerUtils.has_gameplay_authority(
			multiplayer, player
	)


func _on_turn_player_changed(player: GamePlayer) -> void:
	_update_visibility(player)
