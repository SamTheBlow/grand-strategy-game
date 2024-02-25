class_name PlayerListElement
extends Control
## Class for a player as displayed in the player list interface.


@export var container: Control
@export var arrow_label: Label
@export var username_label: Label

var _player: Player


func _on_username_changed(new_username: String) -> void:
	username_label.text = new_username


func _on_player_turn_changed(player: Player) -> void:
	if player == _player:
		arrow_label.text = "->"
	else:
		arrow_label.text = ""


## To be called when this node is created.
func init(player: Player, turn: GameTurn) -> void:
	_player = player
	player.username_changed.connect(_on_username_changed)
	_on_username_changed(player.username())
	turn.player_changed.connect(_on_player_turn_changed)
	_on_player_turn_changed(turn.playing_player())
	custom_minimum_size.y = container.size.y
