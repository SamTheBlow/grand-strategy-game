class_name PlayerTurnAnnouncement
extends Control
## Displays a message when it becomes a player's turn to play, if applicable.
## Automatically fades out after some time.


@export var _game: GameNode

@onready var _animation_player := $AnimationPlayer as AnimationPlayer
@onready var _label := %Message as Label


func _ready() -> void:
	modulate.a = 0.0
	_game.game.turn.player_changed.connect(_on_turn_player_changed)
	_on_turn_player_changed(_game.game.turn.playing_player())


func _on_turn_player_changed(player: GamePlayer) -> void:
	_animation_player.stop()

	# Only announce a new player's turn when there is more than 1 human player
	if _game.game.game_players.number_of_playing_humans() < 2:
		return

	# Only make the announcement when it's a human player's turn
	if not player.is_human:
		return

	_label.text = "It's " + player.username + "'s turn"
	_animation_player.play("new_animation")
