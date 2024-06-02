class_name PlayerTurnAnnouncement
extends Control
## The message that appears when it becomes a player's turn to play.
## Automatically fades out after some time.


@export var _game: Game

@onready var _animation_player := $AnimationPlayer as AnimationPlayer
@onready var _label := %Message as Label


func _ready() -> void:
	modulate.a = 0.0
	_game.turn.player_changed.connect(_on_turn_player_changed)
	_on_turn_player_changed(_game.turn.playing_player())


func _on_turn_player_changed(player: GamePlayer) -> void:
	_animation_player.stop()
	
	# Only announce a new player's turn when there is more than 1 human player
	if _game.game_players.number_of_playing_humans() < 2:
		return
	
	_label.text = "It's " + player.username + "'s turn"
	_animation_player.play("new_animation")
