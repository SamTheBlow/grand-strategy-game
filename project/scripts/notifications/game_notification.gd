class_name GameNotification


signal handled(this: GameNotification)

const DEFAULT_TURNS_BEFORE_DISMISS: int = 3

var _game: Game
var _sender_country: Country
var _recipient_country: Country

## The turn on which this notification was created.
var _creation_turn: int = 1

## The number of turns before this notification is automatically dismissed.
var _turns_before_dismiss: int

## The number of turns before automatically dismissing will only
## go down when the recipient country has seen the notification.
var _was_seen_this_turn: bool

## This is for saving/loading the outcomes (TODO it's bad code)
var diplomacy_action_definition: DiplomacyActionDefinition

var _outcomes: Array[NotificationOutcome] = []


func _init(
		game: Game,
		sender_country_: Country,
		recipient_country: Country,
		outcome_names: Array[String],
		outcome_functions: Array[Callable],
		creation_turn: int = game.turn.current_turn(),
		turns_before_dismiss: int = DEFAULT_TURNS_BEFORE_DISMISS,
		was_seen_this_turn: bool = false,
) -> void:
	_game = game
	_sender_country = sender_country_
	_recipient_country = recipient_country
	_creation_turn = creation_turn
	_turns_before_dismiss = turns_before_dismiss
	_was_seen_this_turn = was_seen_this_turn
	_on_player_changed(game.turn.playing_player())
	
	for i in mini(outcome_names.size(), outcome_functions.size()):
		_outcomes.append(NotificationOutcome.new(
				outcome_names[i], outcome_functions[i]
		))
	
	game.turn.turn_changed.connect(_on_turn_changed)
	game.turn.player_changed.connect(_on_player_changed)


func sender_country() -> Country:
	return _sender_country


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
	handled.emit(self)


func dismiss() -> void:
	handled.emit(self)


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


func _on_player_changed(player: GamePlayer) -> void:
	if player.playing_country == _recipient_country:
		_was_seen_this_turn = true


func _on_turn_changed(_turn: int) -> void:
	if _was_seen_this_turn:
		_turns_before_dismiss -= 1
		if _turns_before_dismiss < 1:
			dismiss()
	_was_seen_this_turn = false


class NotificationOutcome:
	var name: String
	var outcome_function: Callable
	
	func _init(name_: String, outcome_function_: Callable) -> void:
		name = name_
		outcome_function = outcome_function_
