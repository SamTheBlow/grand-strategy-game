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
	_game.game.turn.is_running_changed.connect(_on_is_running_changed)
	_game.game.turn.turn_changed.connect(_on_turn_changed)
	_game.game.turn.player_changed.connect(_on_turn_player_changed)

	# TODO bad code: private function
	_country_button.pressed.connect(_game._on_country_button_pressed)


## Hides the top bar when the game is not running.
func _update_visibility(is_game_running: bool) -> void:
	visible = is_game_running

	if is_game_running:
		_update_turn_label(_game.game.turn.current_turn())
		_update_country(_game.game.turn.playing_player())


func _update_country(player: GamePlayer) -> void:
	var country: Country = player.playing_country

	_country_button.country = country
	_country_name_label.text = country.country_name

	_update_money_label(country.money)
	if _money_changed_signal:
		_money_changed_signal.disconnect(_on_money_changed)
	_money_changed_signal = country.money_changed
	_money_changed_signal.connect(_on_money_changed)


func _update_money_label(money: int) -> void:
	_country_money_label.text = str(money)


func _update_turn_label(turn: int) -> void:
	_game_turn_label.text = "Turn " + str(turn)


func _on_is_running_changed(is_game_running: bool) -> void:
	_update_visibility(is_game_running)


func _on_money_changed(new_amount: int) -> void:
	_update_money_label(new_amount)


func _on_turn_changed(new_turn: int) -> void:
	_update_turn_label(new_turn)


func _on_turn_player_changed(player: GamePlayer) -> void:
	_update_country(player)
