class_name GameNotificationPerformedAction
extends GameNotification
## Informs of a diplomatic action performed by another country.


var _sender_country: Country
var _diplomacy_action_definition: DiplomacyActionDefinition


func _init(
		game: Game,
		recipient_country: Country,
		sender_country_: Country,
		diplomacy_action_definition: DiplomacyActionDefinition,
		creation_turn: int = game.turn.current_turn(),
		turns_before_dismiss: int = DEFAULT_TURNS_BEFORE_DISMISS,
		was_seen_this_turn: bool = false,
) -> void:
	super._init(
			game, recipient_country,
			creation_turn, turns_before_dismiss, was_seen_this_turn
	)
	_sender_country = sender_country_
	_diplomacy_action_definition = diplomacy_action_definition


func sender_country() -> Country:
	return _sender_country


func action_id() -> int:
	return _diplomacy_action_definition.id


func icon() -> String:
	return _diplomacy_action_definition.icon


func description() -> String:
	return (
			_sender_country.country_name
			+ ' performed this action: "'
			+ _diplomacy_action_definition.name + '"'
	)
