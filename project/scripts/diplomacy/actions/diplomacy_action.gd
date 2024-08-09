class_name DiplomacyAction


signal performed(this: DiplomacyAction)

var _definition: DiplomacyActionDefinition

var _turn_it_became_available: int

## Diplomatic actions may only be performed once per turn.
var _was_performed_this_turn: bool = false


func _init(
		definition: DiplomacyActionDefinition,
		turn_changed_signal: Signal,
		turn_it_became_available: int = 1,
		was_performed_this_turn_: bool = false,
) -> void:
	_definition = definition
	_turn_it_became_available = turn_it_became_available
	_was_performed_this_turn = was_performed_this_turn_
	turn_changed_signal.connect(_on_turn_changed)


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
	
	if _was_performed_this_turn:
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


func was_performed_this_turn() -> bool:
	return _was_performed_this_turn


## Applies this action to given relationships.
func apply(
		game: Game,
		relationship: DiplomacyRelationship,
		reverse_relationship: DiplomacyRelationship
) -> void:
	if not is_valid(relationship, true):
		return
	
	if not can_be_performed(game, true):
		return
	
	if _definition.requires_consent:
		relationship.recipient_country.notifications.add(
				_definition.new_notification(
						game, relationship, reverse_relationship
				)
		)
	else:
		_definition.apply_action_data(
				relationship, reverse_relationship, game.turn.current_turn()
		)
	
	_was_performed_this_turn = true
	performed.emit(self)


func _on_turn_changed(_turn: int) -> void:
	_was_performed_this_turn = false
