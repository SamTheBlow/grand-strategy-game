@tool
class_name PlayerListElement
extends Control
## Class for a player as displayed in the player list interface.


@export_category("Child nodes")
@export var color_rect: ColorRect
@export var container: Control
@export var arrow_container: Control
@export var arrow_label: Label
@export var username_label: Label

@export_category("Variables")
@export var username_color_human: Color
@export var username_color_ai: Color
@export var bg_color_human: Color
@export var bg_color_ai: Color


var _player: Player


func _on_username_changed(_new_username: String) -> void:
	_update_shown_username()


func _on_player_turn_changed(playing_player: Player) -> void:
	_update_turn_indicator(playing_player)


## To be called when this node is created.
func init(player: Player) -> void:
	_player = player
	
	player.username_changed.connect(_on_username_changed)
	_update_shown_username()
	
	arrow_label.text = ""
	_update_appearance()
	custom_minimum_size.y = container.size.y


## To be called when this node is created, if the game is turn-based
func init_turn(turn: GameTurn) -> void:
	turn.player_changed.connect(_on_player_turn_changed)
	_update_turn_indicator(turn.playing_player())


func _update_shown_username() -> void:
	username_label.text = _player.username()


func _update_turn_indicator(playing_player: Player) -> void:
	if playing_player == _player:
		arrow_label.text = "->"
	else:
		arrow_label.text = ""


func _update_appearance() -> void:
	if _player.is_human:
		username_label.add_theme_color_override(
				"font_color", username_color_human
		)
		color_rect.color = bg_color_human
	else:
		username_label.add_theme_color_override(
				"font_color", username_color_ai
		)
		color_rect.color = bg_color_ai
