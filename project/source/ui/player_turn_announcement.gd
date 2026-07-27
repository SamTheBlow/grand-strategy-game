class_name PlayerTurnAnnouncement
extends Control
## Displays a message when it becomes a player's turn to play, if applicable.
## Automatically fades out after some time.

@export var _game: GameNode

@onready var _animation_player := $AnimationPlayer as AnimationPlayer
@onready var _label := %Message as Label


func _ready() -> void:
	modulate.a = 0.0
	_game.game.turn.playing_country_changed.connect(_refresh)
	_refresh()


func _refresh(_country: Country = null) -> void:
	_animation_player.stop()

	# Only announce a new player's turn when there is more than 1 human player
	if _game.game.game_players.number_of_playing_humans() < 2:
		return

	var playing_players: Array[GamePlayer] = _game.game.turn.playing_players()
	if playing_players.is_empty():
		return
	var player: GamePlayer = playing_players[0]

	# Only make the announcement when it's a human player's turn
	if not player.is_human:
		return

	_label.text = "It's " + player.username_or_default() + "'s turn"
	_animation_player.play(&"new_animation")
