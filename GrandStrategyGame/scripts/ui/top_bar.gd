class_name TopBar
extends Control
## The top bar that appears during a game.


@export var country_color_rect: ColorRect
@export var country_name_label: Label

@export var country_money_label: Label

@export var game_turn_label: Label


func _on_money_changed(new_amount: int) -> void:
	_update_money_label(new_amount)


func _on_turn_changed(new_turn: int) -> void:
	_update_turn_label(new_turn)


## To be called when a game is loaded.
func init(game: Game) -> void:
	var your_country: Country = (
			game.players.player_from_id(game._your_id).playing_country
	)
	country_color_rect.color = your_country.color
	country_name_label.text = your_country.country_name
	
	_update_money_label(your_country.money)
	your_country.money_changed.connect(_on_money_changed)
	
	_update_turn_label(game.turn.current_turn())
	game.turn.turn_changed.connect(_on_turn_changed)


func _update_money_label(money: int) -> void:
	country_money_label.text = str(money)


func _update_turn_label(turn: int) -> void:
	game_turn_label.text = "Turn " + str(turn)
