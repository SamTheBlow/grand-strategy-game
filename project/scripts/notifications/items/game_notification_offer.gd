class_name GameNotificationOffer
extends GameNotification
## Informs of a diplomatic offer sent by another country.


var _sender_country: Country
var _diplomacy_action_definition: DiplomacyActionDefinition

var _components: Array = []


func _init(
		game: Game,
		recipient_country: Country,
		sender_country_: Country,
		diplomacy_action_definition: DiplomacyActionDefinition,
		creation_turn_: int = game.turn.current_turn(),
		turns_before_dismiss: int = DEFAULT_TURNS_BEFORE_DISMISS,
		was_seen_this_turn: bool = false,
) -> void:
	super._init(
			game, recipient_country,
			creation_turn_, turns_before_dismiss, was_seen_this_turn
	)
	_sender_country = sender_country_
	_diplomacy_action_definition = diplomacy_action_definition
	
	_components.append(AutoDismissInvalidOffer.new(
			self,
			_sender_country.relationships.with_country(_recipient_country)
			.available_actions_changed
	))
	
	_outcome_names = ["Accept", "Decline"]
	_outcome_functions = [_accept, func() -> void: pass]


func sender_country() -> Country:
	return _sender_country


func action_id() -> int:
	return _diplomacy_action_definition.id


func icon() -> String:
	return _diplomacy_action_definition.icon


func description() -> String:
	return (
			_sender_country.country_name
			+ ' is offering: "'
			+ _diplomacy_action_definition.name + '"'
	)


func _accept() -> void:
	_diplomacy_action_definition.apply_action_data(
			_sender_country.relationships
			.with_country(_recipient_country),
			_recipient_country.relationships
			.with_country(_sender_country),
			_game.turn.current_turn()
	)
	
	var new_notification := GameNotificationOfferAccepted.new(
			_game,
			_sender_country,
			_recipient_country,
			_diplomacy_action_definition
	)
	new_notification.id = _sender_country.notifications.new_unique_id()
	_sender_country.notifications.add(new_notification)
