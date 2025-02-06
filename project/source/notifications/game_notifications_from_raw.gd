class_name GameNotificationsFromRaw
## Converts raw data into a [GameNotifications].
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
##
## See also: [GameNotificationsToRaw]

const ID_KEY: String = "id"
const CREATION_TURN_KEY: String = "creation_turn"
const TURNS_BEFORE_DISMISS_KEY: String = "turns_before_dismiss"
const WAS_SEEN_THIS_TURN_KEY: String = "was_seen_this_turn"

const TYPE_KEY: String = "type"
const TYPE_OFFER: String = "OFFER"
const TYPE_OFFER_ACCEPTED: String = "OFFER ACCEPTED"
const TYPE_PERFORMED_ACTION: String = "ACTION PERFORMED"

const SENDER_COUNTRY_ID_KEY: String = "sender_country_id"
const DIPLOMACY_ACTION_ID_KEY: String = "diplomacy_action_id"


static func parse_using(
		raw_data: Variant, game: Game, country: Country
) -> void:
	country.notifications = GameNotifications.new()

	if raw_data is not Array:
		return
	var raw_array: Array = raw_data

	for notification_data: Variant in raw_array:
		_parse_game_notification(notification_data, game, country)


## This operation may fail, in which case it has no effect.
static func _parse_game_notification(
		raw_data: Variant, game: Game, recipient_country: Country
) -> void:
	# Fails if the raw data isn't a dictionary
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Notification id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, ID_KEY):
		return
	var id: int = ParseUtils.dictionary_int(raw_dict, ID_KEY)

	# The id must be valid and available.
	if not recipient_country.notifications.id_system().is_id_available(id):
		return

	# Creation turn
	var creation_turn: int = game.turn.current_turn()
	if ParseUtils.dictionary_has_number(raw_dict, CREATION_TURN_KEY):
		creation_turn = ParseUtils.dictionary_int(raw_dict, CREATION_TURN_KEY)

	# Turns before dismiss
	var turns_before_dismiss: int = GameNotification.DEFAULT_TURNS_BEFORE_DISMISS
	if ParseUtils.dictionary_has_number(raw_dict, TURNS_BEFORE_DISMISS_KEY):
		turns_before_dismiss = (
				ParseUtils.dictionary_int(raw_dict, TURNS_BEFORE_DISMISS_KEY)
		)

	# Was seen this turn
	var was_seen_this_turn: bool = false
	if ParseUtils.dictionary_has_bool(raw_dict, WAS_SEEN_THIS_TURN_KEY):
		was_seen_this_turn = raw_dict[WAS_SEEN_THIS_TURN_KEY]

	var new_notification: GameNotification
	var type: Variant = raw_dict[TYPE_KEY] if raw_dict.has(TYPE_KEY) else null
	match type:
		TYPE_OFFER:
			var action_definition: DiplomacyActionDefinition = (
					_action_definition(raw_dict, game)
			)
			if action_definition == null:
				return

			var sender_country: Country = _sender_country(raw_dict, game)
			if sender_country == null:
				return

			new_notification = GameNotificationOffer.new(
					game,
					recipient_country,
					sender_country,
					action_definition,
					creation_turn,
					turns_before_dismiss,
					was_seen_this_turn,
			)
		TYPE_OFFER_ACCEPTED:
			var action_definition: DiplomacyActionDefinition = (
					_action_definition(raw_dict, game)
			)
			if action_definition == null:
				return

			var sender_country: Country = _sender_country(raw_dict, game)
			if sender_country == null:
				return

			new_notification = GameNotificationOfferAccepted.new(
					game,
					recipient_country,
					sender_country,
					action_definition,
					creation_turn,
					turns_before_dismiss,
					was_seen_this_turn,
			)
		TYPE_PERFORMED_ACTION:
			var action_definition: DiplomacyActionDefinition = (
					_action_definition(raw_dict, game)
			)
			if action_definition == null:
				return

			var sender_country: Country = _sender_country(raw_dict, game)
			if sender_country == null:
				return

			new_notification = GameNotificationPerformedAction.new(
					game,
					recipient_country,
					sender_country,
					action_definition,
					creation_turn,
					turns_before_dismiss,
					was_seen_this_turn,
			)
		_:
			new_notification = GameNotification.new(
					game,
					recipient_country,
					creation_turn,
					turns_before_dismiss,
					was_seen_this_turn,
			)

	recipient_country.notifications.add(new_notification, id)


## May fail and return null.
static func _action_definition(
		raw_dict: Dictionary, game: Game
) -> DiplomacyActionDefinition:
	var output: DiplomacyActionDefinition

	if ParseUtils.dictionary_has_number(raw_dict, DIPLOMACY_ACTION_ID_KEY):
		var action_id: int = (
				ParseUtils.dictionary_int(raw_dict, DIPLOMACY_ACTION_ID_KEY)
		)
		output = game.rules.diplomatic_actions.action_from_id(action_id)

	return output


## May fail and return null.
static func _sender_country(raw_dict: Dictionary, game: Game) -> Country:
	if not ParseUtils.dictionary_has_number(raw_dict, SENDER_COUNTRY_ID_KEY):
		return null
	var sender_country_id: int = (
			ParseUtils.dictionary_int(raw_dict, SENDER_COUNTRY_ID_KEY)
	)

	return game.countries.country_from_id(sender_country_id)
