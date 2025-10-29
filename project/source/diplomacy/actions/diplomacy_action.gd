class_name DiplomacyAction
## Remembers and updates whether or not
## a given [DiplomacyActionDefinition] can be performed.
## This is also the starting point for performing the action.

signal performed(this: DiplomacyAction)

var _definition: DiplomacyActionDefinition

## Ensures this diplomatic action can only
## be performed after a certain number of turns have passed.
## By default, a value of 1 means it's always available.
var _turn_it_became_available: int

## Ensures this diplomatic action can only be performed once per turn.
## By default, a value of 0 means it was never performed.
var _turn_it_was_last_performed: int


func _init(
		definition: DiplomacyActionDefinition,
		turn_it_became_available: int = 1,
		turn_it_was_last_performed: int = 0,
) -> void:
	_definition = definition
	_turn_it_became_available = turn_it_became_available
	_turn_it_was_last_performed = turn_it_was_last_performed


## Returns the id of this action's definition.
## All actions have their own unique id.
func id() -> int:
	return _definition.id


## Use this to check if this action is valid in given context.
## Then, use [code]can_be_performed[/code] to check if it can be performed.
func is_valid(
		relationship: DiplomacyRelationship,
		push_errors: bool = false
) -> bool:
	if not relationship.action_is_available(id()):
		if push_errors:
			push_error(
					"Tried to perform a diplomatic action that isn't"
					+ " available. (Diplomacy action id: " + str(id()) + ")"
			)
		return false

	return true


func can_be_performed(game: Game, push_debug_errors: bool = false) -> bool:
	var result: bool = true

	var warning_message: String = (
			'Tried to perform a diplomatic action ("'
			+ _definition.name
			+ '"), but it currently cannot be performed.'
	)

	var turns_remaining: int = cooldown_turns_remaining(game)
	if turns_remaining > 0:
		result = false
		warning_message += (
				"\nThe action still has a cooldown of "
				+ str(turns_remaining)
				+ " turn" + ("" if turns_remaining == 1 else "s") + "."
		)

	if was_performed_this_turn(game):
		result = false
		warning_message += "\nThe action was already performed this turn."

	if result == false and push_debug_errors:
		push_warning(warning_message)

	return result


## The number of turns before this action can be performed.
## Returns zero if the action can already be performed.
func cooldown_turns_remaining(game: Game) -> int:
	return maxi(
			0,
			_definition.available_after_turns
			- (game.turn.current_turn() - _turn_it_became_available)
	)


func was_performed_this_turn(game: Game) -> bool:
	return _turn_it_was_last_performed == game.turn.current_turn()


## Performs the action, if possible.
func perform(
		game: Game,
		relationship: DiplomacyRelationship,
		reverse_relationship: DiplomacyRelationship
) -> void:
	if not (is_valid(relationship, true) and can_be_performed(game, true)):
		return

	var new_notification: GameNotification
	if _definition.requires_consent:
		new_notification = GameNotificationOffer.new(
				game,
				relationship.recipient_country,
				relationship.source_country,
				_definition
		)
	else:
		_definition.apply_action_data(
				relationship, reverse_relationship, game.turn.current_turn()
		)

		new_notification = GameNotificationPerformedAction.new(
				game,
				relationship.recipient_country,
				relationship.source_country,
				_definition
		)

	relationship.recipient_country.notifications.add(new_notification)

	_turn_it_was_last_performed = game.turn.current_turn()
	performed.emit(self)
