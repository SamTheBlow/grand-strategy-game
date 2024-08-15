class_name GameNotificationsFromRaw
## Converts given raw data into a [GameNotifications] object.


const TYPE_KEY: String = "type"
const TYPE_OFFER: String = "OFFER"
const TYPE_OFFER_ACCEPTED: String = "OFFER ACCEPTED"
const TYPE_PERFORMED_ACTION: String = "ACTION PERFORMED"

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
	
	var game_notifications := GameNotifications.new()
	
	for data_element: Variant in data_array:
		if not data_element is Dictionary:
			error = true
			error_message = "Notification data is not a dictionary."
			return
		var data_dict := data_element as Dictionary
		
		var game_notification: GameNotification = (
				_game_notification_from_dict(game, country, data_dict)
		)
		if error:
			return
		game_notifications.add(game_notification)
	
	result = game_notifications


## Returns null if an error occured.
func _game_notification_from_dict(
		game: Game, recipient_country: Country, data: Dictionary
) -> GameNotification:
	if not ParseUtils.dictionary_has_number(data, "id"):
		error = true
		error_message = "Game notification data doesn't have an id."
		return null
	var id: int = ParseUtils.dictionary_int(data, "id")
	
	var creation_turn: int = game.turn.current_turn()
	if ParseUtils.dictionary_has_number(data, "creation_turn"):
		creation_turn = ParseUtils.dictionary_int(data, "creation_turn")
	
	var turns_before_dismiss: int = (
			GameNotification.DEFAULT_TURNS_BEFORE_DISMISS
	)
	if ParseUtils.dictionary_has_number(data, "turns_before_dismiss"):
		turns_before_dismiss = (
				ParseUtils.dictionary_int(data, "turns_before_dismiss")
		)
	
	var was_seen_this_turn: bool = false
	if ParseUtils.dictionary_has_bool(data, "was_seen_this_turn"):
		was_seen_this_turn = data["was_seen_this_turn"]
	
	var new_notification: GameNotification
	var type: Variant = data[TYPE_KEY] if data.has(TYPE_KEY) else null
	match type:
		TYPE_OFFER:
			var action_definition: DiplomacyActionDefinition = (
					_action_definition(game, data)
			)
			if action_definition == null:
				return null
			
			var sender_country: Country = _sender_country(game, data)
			if sender_country == null:
				return null
			
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
				return null
			
			var sender_country: Country = _sender_country(game, data)
			if sender_country == null:
				return null
			
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
				return null
			
			var sender_country: Country = _sender_country(game, data)
			if sender_country == null:
				return null
			
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
	
	new_notification.id = id
	return new_notification


func _action_definition(
		game: Game, data: Dictionary
) -> DiplomacyActionDefinition:
	var output: DiplomacyActionDefinition
	
	if ParseUtils.dictionary_has_number(data, "diplomacy_action_id"):
		var action_id: int = (
				ParseUtils.dictionary_int(data, "diplomacy_action_id")
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
	if not ParseUtils.dictionary_has_number(data, "sender_country_id"):
		error = true
		error_message = (
				"Game notification data doesn't contain a sender country id."
		)
		return null
	var sender_country_id: int = (
			ParseUtils.dictionary_int(data, "sender_country_id")
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
