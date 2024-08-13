class_name GameNotificationsFromRaw
## Converts given raw data into a [GameNotifications] object.


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
	
	if not ParseUtils.dictionary_has_number(data, "diplomacy_action_id"):
		new_notification = GameNotification.new(
				game,
				sender_country,
				recipient_country,
				["OK"],
				[func() -> void: pass]
		)
	else:
		var action_id: int = (
				ParseUtils.dictionary_int(data, "diplomacy_action_id")
		)
		var action: DiplomacyActionDefinition = (
				game.rules.diplomatic_actions.action_from_id(action_id)
		)
		new_notification = action.new_notification(
				game,
				sender_country.relationships.with_country(recipient_country),
				recipient_country.relationships.with_country(sender_country),
				creation_turn,
				turns_before_dismiss,
				was_seen_this_turn,
		)
	
	new_notification.id = id
	return new_notification
