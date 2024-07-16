class_name DiplomacyAction


var _definition: DiplomacyActionDefinition

var _turn_it_became_available: int


func _init(
		definition: DiplomacyActionDefinition,
		turn_it_became_available: int = 1
) -> void:
	_definition = definition
	_turn_it_became_available = turn_it_became_available


## Returns the id of this action's definition.
## All actions have their own unique id.
func id() -> int:
	return _definition.id


func can_be_performed(game: Game) -> bool:
	return cooldown_turns_remaining(game) == 0


## The number of turns before this action can be performed.
## Returns zero if the action can already be performed.
func cooldown_turns_remaining(game: Game) -> int:
	return maxi(
			0,
			_definition.available_after_turns
			- (game.turn.current_turn() - _turn_it_became_available)
	)


## Applies this action to given relationships.
func apply(
		game: Game,
		relationship: DiplomacyRelationship,
		reverse_relationship: DiplomacyRelationship
) -> void:
	if not relationship.action_is_available(id()):
		print_debug(
				"Tried to perform a diplomatic action that isn't available."
		)
		return
	
	var current_turn: int = game.turn.current_turn()
	if not can_be_performed(game):
		var turns_remaining: int = cooldown_turns_remaining(game)
		print_debug(
				"Tried to perform a diplomatic action, but "
				#+ "it currently cannot be performed."
				+ "it still has a cooldown of " + str(turns_remaining)
				+ " turn" + ("" if turns_remaining == 1 else "s") + "."
		)
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
