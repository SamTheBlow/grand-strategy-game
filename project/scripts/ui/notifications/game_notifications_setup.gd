extends Node
## Initializes and updates given [GameNotificationsNode]
## to always use the playing player in given [Game].


@export var game_notifications_node: GameNotificationsNode
@export var _game: GameNode


func _ready() -> void:
	if not game_notifications_node or not _game:
		return
	
	game_notifications_node.game_player = _game.game.turn.playing_player()
	_game.game.turn.player_changed.connect(_on_turn_player_changed)


func _on_turn_player_changed(playing_player: GamePlayer) -> void:
	if not game_notifications_node:
		return
	game_notifications_node.game_player = playing_player
