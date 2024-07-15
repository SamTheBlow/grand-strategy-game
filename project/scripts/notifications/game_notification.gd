class_name GameNotification


signal handled()

var _game: Game
var _sender_country: Country
var _recipient_country: Country

## The turn on which this notification was created.
var _creation_turn: int = 1

var _outcomes: Array[NotificationOutcome] = []


func _init(
		game: Game,
		sender_country: Country,
		recipient_country: Country,
		outcome_names: Array[String],
		outcome_functions: Array[Callable]
) -> void:
	_game = game
	_sender_country = sender_country
	_recipient_country = recipient_country
	
	for i in mini(outcome_names.size(), outcome_functions.size()):
		_outcomes.append(NotificationOutcome.new(
				outcome_names[i], outcome_functions[i]
		))
	
	_creation_turn = game.turn.current_turn()
	game.turn.turn_changed.connect(_on_turn_changed)


func select_outcome(outcome_index: int) -> void:
	if not _outcome_can_be_selected():
		return
	
	if outcome_index < 0:
		dismiss()
		return
	elif outcome_index >= _outcomes.size():
		push_error(
				"Tried to select a notification's outcome, but "
				+ "the given outcome index is out of bounds! "
				+ "The notification will be dismissed."
		)
		dismiss()
		return
	
	_outcomes[outcome_index].outcome_function.call()
	handled.emit()


func dismiss() -> void:
	handled.emit()


func _outcome_can_be_selected() -> bool:
	if _game == null:
		return true
	
	var playing_country: Country = _game.turn.playing_player().playing_country
	
	if playing_country != _recipient_country:
		push_warning(
				"Tried to select an outcome for a notification, but "
				+ "a country cannot handle another country's notifications!"
		)
		return false
	
	return true


## Automatically dismiss the notification after a certain amount of time
func _on_turn_changed(turn: int) -> void:
	var dismiss_cooldown: int = 3
	
	if turn - _creation_turn >= dismiss_cooldown:
		dismiss()


class NotificationOutcome:
	var name: String
	var outcome_function: Callable
	
	func _init(name_: String, outcome_function_: Callable) -> void:
		name = name_
		outcome_function = outcome_function_
