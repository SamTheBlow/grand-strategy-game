class_name TopBar
extends Control
## The top bar that appears during a game.
## Shows useful information to the user.

@export var _game: GameNode

# We need to store this so that we can disconnect it later
var _money_changed_signal: Signal

@onready var _country_button := %CountryButton as CountryButton
@onready var _country_name_label := %CountryNameLabel as Label
@onready var _country_money_label := %CountryMoneyLabel as Label
@onready var _game_turn_label := %GameTurnLabel as Label


func _ready() -> void:
	if _game == null:
		push_error("No game was provided to top bar.")
		return

	_update_visibility(_game.game.turn.is_running())
	_game.game.turn.is_running_changed.connect(_update_visibility)
	_game.game.turn.turn_changed.connect(_update_turn_label)
	_game.game.turn.playing_country_changed.connect(_update_country)


## Hides the top bar when the game is not running.
func _update_visibility(is_game_running: bool) -> void:
	visible = is_game_running

	if is_game_running:
		_update_turn_label(_game.game.turn.current_turn())
		_update_country(_game.game.turn.playing_country())


func _update_country(country: Country) -> void:
	_country_button.country = country
	_country_name_label.text = country.name_or_default()

	_update_money_label(country.money)

	if _money_changed_signal:
		_money_changed_signal.disconnect(_update_money_label)
	_money_changed_signal = country.money_changed
	_money_changed_signal.connect(_update_money_label)


func _update_money_label(money: int) -> void:
	_country_money_label.text = str(money)


func _update_turn_label(turn: int) -> void:
	_game_turn_label.text = "Turn " + str(turn)
