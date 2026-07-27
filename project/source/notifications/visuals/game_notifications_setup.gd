extends Node
## Initializes and updates given [GameNotificationsNode]
## to always use the playing player in given [Game].

@export var _game_notifications_node: GameNotificationsNode
@export var _game: GameNode


func _ready() -> void:
	if _game_notifications_node == null or _game == null:
		push_error("An export variable is null, oops.")
		return

	_game.game.game_started.connect(_update_player)
	_game.game.turn.playing_country_changed.connect(_update_player)


func _update_player(_playing_country: Country = null) -> void:
	var playing_players: Array[GamePlayer] = _game.game.turn.playing_players()
	if playing_players.is_empty():
		return
	var playing_player: GamePlayer = playing_players[0]

	if MultiplayerUtils.has_gameplay_authority(multiplayer, playing_player):
		_game_notifications_node.game_player = playing_player
	else:
		_game_notifications_node.game_player = null
