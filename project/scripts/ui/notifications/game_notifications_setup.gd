extends Node
## Initializes and updates given [GameNotificationsNode]
## to always use the playing player in given [Game].


@export var game_notifications_node: GameNotificationsNode
@export var game: Game


func _ready() -> void:
	if not game_notifications_node or not game:
		return
	
	game_notifications_node.game_player = game.turn.playing_player()
	game.turn.player_changed.connect(_on_turn_player_changed)


func _on_turn_player_changed(playing_player: GamePlayer) -> void:
	if not game_notifications_node:
		return
	game_notifications_node.game_player = playing_player
