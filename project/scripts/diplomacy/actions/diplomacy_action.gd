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


func can_be_performed(game: Game) -> bool:
	return cooldown_turns_remaining(game) == 0 and not _was_performed_this_turn


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
	if not relationship.action_is_available(id()):
		print_debug(
				"Tried to perform a diplomatic action that isn't available."
				+ " (Diplomacy action id: " + str(id()) + ")"
		)
		return
	
	var current_turn: int = game.turn.current_turn()
	if not can_be_performed(game):
		var debug_message: String = (
				'Tried to perform a diplomatic action ("'
				+ _definition.name
				+ '"), but it currently cannot be performed.'
		)
		
		var turns_remaining: int = cooldown_turns_remaining(game)
		if turns_remaining > 0:
			debug_message += (
					"\nThe action still has a cooldown of "
					+ str(turns_remaining)
					+ " turn" + ("" if turns_remaining == 1 else "s") + "."
			)
		
		if _was_performed_this_turn:
			debug_message += "\nThe action was already performed this turn."
		
		print_debug(debug_message)
		return
	
	if _definition.requires_consent:
		relationship.recipient_country.notifications.add(
				_definition.new_notification(
						game, relationship, reverse_relationship
				)
		)
	else:
		_definition.apply_action_data(
				relationship, reverse_relationship, current_turn
		)
	
	_was_performed_this_turn = true
	performed.emit(self)


func _on_turn_changed(_turn: int) -> void:
	_was_performed_this_turn = false
