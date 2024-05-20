class_name TopBar
extends Control
## The top bar that appears during a game.


@export_group("External nodes")
@export var _game: Game

@export_group("Child nodes")
@export var country_color_rect: ColorRect
@export var country_name_label: Label
@export var country_money_label: Label
@export var game_turn_label: Label

# We need to save this so that we can disconnect it later
var _money_changed_signal: Signal


func _ready() -> void:
	_update_turn_label(_game.turn.current_turn())
	_game.turn.turn_changed.connect(_on_turn_changed)


func set_playing_country(country: Country) -> void:
	country_color_rect.color = country.color
	country_name_label.text = country.country_name
	
	_update_money_label(country.money)
	if _money_changed_signal:
		_money_changed_signal.disconnect(_on_money_changed)
	_money_changed_signal = country.money_changed
	_money_changed_signal.connect(_on_money_changed)


func _update_money_label(money: int) -> void:
	country_money_label.text = str(money)


func _update_turn_label(turn: int) -> void:
	game_turn_label.text = "Turn " + str(turn)


func _on_money_changed(new_amount: int) -> void:
	_update_money_label(new_amount)


func _on_turn_changed(new_turn: int) -> void:
	_update_turn_label(new_turn)
