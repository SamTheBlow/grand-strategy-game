class_name TopBar
extends Control
## The top bar that appears during a game.


@export var country_color_rect: ColorRect
@export var country_name_label: Label

@export var country_money_label: Label

@export var game_turn_label: Label


## To be called when a game is loaded.
func init(game: Game) -> void:
	var your_country: Country = (
			game.players.player_from_id(game._your_id).playing_country
	)
	country_color_rect.color = your_country.color
	country_name_label.text = your_country.country_name
	country_money_label.text = str(your_country.money)
	game_turn_label.text = "Turn " + str(game.turn.current_turn())
