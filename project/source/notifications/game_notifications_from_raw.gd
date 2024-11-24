class_name GameNotificationsFromRaw
## Converts given raw data into a [GameNotifications] object.


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

var error: bool = false
var error_message: String = ""
var result: GameNotifications


func apply(game: Game, country: Country, data: Variant) -> void:
	error = false
	error_message = ""

	if not data is Array:
		error = true
		error_message = "Notification list is not an array."
		return
	var data_array := data as Array

	result = GameNotifications.new()

	for data_element: Variant in data_array:
		if not data_element is Dictionary:
			error = true
			error_message = "Notification data is not a dictionary."
			result = null
			return
		var data_dict := data_element as Dictionary

		_game_notification_from_dict(game, country, data_dict)
		if error:
			result = null
			return


func _game_notification_from_dict(
		game: Game, recipient_country: Country, data: Dictionary
) -> void:
	# Notification ID (mandatory)
	if not ParseUtils.dictionary_has_number(data, ID_KEY):
		error = true
		error_message = "Game notification data doesn't have an id."
		return
	var id: int = ParseUtils.dictionary_int(data, ID_KEY)

	# Verify that the id is valid and available.
	# If not, then the entire data is invalid.
	if not result.id_system().is_id_available(id):
		error = true
		error_message = (
				"Found an invalid GameNotification id."
				+ " Perhaps another notification has the same id?"
				+ " (id: " + str(id) + ")"
		)
		return

	var creation_turn: int = game.turn.current_turn()
	if ParseUtils.dictionary_has_number(data, CREATION_TURN_KEY):
		creation_turn = ParseUtils.dictionary_int(data, CREATION_TURN_KEY)

	var turns_before_dismiss: int = (
			GameNotification.DEFAULT_TURNS_BEFORE_DISMISS
	)
	if ParseUtils.dictionary_has_number(data, TURNS_BEFORE_DISMISS_KEY):
		turns_before_dismiss = (
				ParseUtils.dictionary_int(data, TURNS_BEFORE_DISMISS_KEY)
		)

	var was_seen_this_turn: bool = false
	if ParseUtils.dictionary_has_bool(data, WAS_SEEN_THIS_TURN_KEY):
		was_seen_this_turn = data[WAS_SEEN_THIS_TURN_KEY]

	var new_notification: GameNotification
	var type: Variant = data[TYPE_KEY] if data.has(TYPE_KEY) else null
	match type:
		TYPE_OFFER:
			var action_definition: DiplomacyActionDefinition = (
					_action_definition(game, data)
			)
			if action_definition == null:
				error = true
				error_message = "Action definition is null."
				return

			var sender_country: Country = _sender_country(game, data)
			if sender_country == null:
				error = true
				error_message = "Sender country is null."
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
			# TODO DRY. Too much copy/paste here
			var action_definition: DiplomacyActionDefinition = (
					_action_definition(game, data)
			)
			if action_definition == null:
				error = true
				error_message = "Action definition is null."
				return

			var sender_country: Country = _sender_country(game, data)
			if sender_country == null:
				error = true
				error_message = "Sender country is null."
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
					_action_definition(game, data)
			)
			if action_definition == null:
				error = true
				error_message = "Action definition is null."
				return

			var sender_country: Country = _sender_country(game, data)
			if sender_country == null:
				error = true
				error_message = "Sender country is null."
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

	result.add(new_notification, id)


func _action_definition(
		game: Game, data: Dictionary
) -> DiplomacyActionDefinition:
	var output: DiplomacyActionDefinition

	if ParseUtils.dictionary_has_number(data, DIPLOMACY_ACTION_ID_KEY):
		var action_id: int = (
				ParseUtils.dictionary_int(data, DIPLOMACY_ACTION_ID_KEY)
		)
		output = game.rules.diplomatic_actions.action_from_id(action_id)

	if output == null:
		error = true
		error_message = (
				"Game notification data doesn't have a valid"
				+ " diplomacy action definition."
		)
	return output


func _sender_country(game: Game, data: Dictionary) -> Country:
	if not ParseUtils.dictionary_has_number(data, SENDER_COUNTRY_ID_KEY):
		error = true
		error_message = (
				"Game notification data doesn't contain a sender country id."
		)
		return null
	var sender_country_id: int = (
			ParseUtils.dictionary_int(data, SENDER_COUNTRY_ID_KEY)
	)

	var sender_country: Country = (
			game.countries.country_from_id(sender_country_id)
	)
	if sender_country == null or sender_country_id < 0:
		error = true
		error_message = (
				"Game notification data has an invalid sender country id. "
				+ "(Id: " + str(sender_country_id)
				+ ") Perhaps there isn't a country with that id."
		)
		return null

	return sender_country
