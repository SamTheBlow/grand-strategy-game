extends Node
## Initializes and updates given [GameNotificationsNode]
## to always use the playing player in given [Game].


@export var _game_notifications_node: GameNotificationsNode
@export var _game: GameNode


func _ready() -> void:
	if _game_notifications_node == null or _game == null:
		push_error("An export variable is null, oops.")
		return

	_game.game.game_started.connect(_on_game_started)
	_game.game.turn.player_changed.connect(_on_turn_player_changed)


func _update_player(playing_player: GamePlayer) -> void:
	if MultiplayerUtils.has_gameplay_authority(multiplayer, playing_player):
		_game_notifications_node.game_player = playing_player
	else:
		_game_notifications_node.game_player = null


func _on_game_started() -> void:
	_update_player(_game.game.turn.playing_player())


func _on_turn_player_changed(playing_player: GamePlayer) -> void:
	if _game_notifications_node == null:
		return

	_update_player(playing_player)
