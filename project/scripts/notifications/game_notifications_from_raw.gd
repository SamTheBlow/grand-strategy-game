class_name GameNotificationsFromRaw
## Converts given raw data into a [GameNotifications] object.


var error: bool = false
var error_message: String = ""
var result: GameNotifications


func apply(game: Game, data: Variant) -> void:
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
				_game_notification_from_dict(game, data_dict)
		)
		if error:
			return
		game_notifications.add(game_notification)
	
	result = game_notifications


## Returns null if an error occured.
func _game_notification_from_dict(
		game: Game, data: Dictionary
) -> GameNotification:
	if not (
			data.has("sender_country_id")
			and typeof(data["sender_country_id"]) in [TYPE_INT, TYPE_FLOAT]
	):
		error = true
		error_message = (
				"Game notification data doesn't contain a sender country id."
		)
		return null
	var sender_country_id: int = roundi(data["sender_country_id"])
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
	
	if not (
			data.has("recipient_country_id")
			and typeof(data["recipient_country_id"]) in [TYPE_INT, TYPE_FLOAT]
	):
		error = true
		error_message = (
				"Game notification data doesn't contain "
				+ "a recipient country id."
		)
		return null
	var recipient_country_id: int = roundi(data["recipient_country_id"])
	var recipient_country: Country = (
			game.countries.country_from_id(recipient_country_id)
	)
	if recipient_country == null or recipient_country_id < 0:
		error = true
		error_message = (
				"Game notification data has an invalid recipient country id. "
				+ "(Id: " + str(recipient_country_id)
				+ ") Perhaps there isn't a country with that id."
		)
		return null
	
	var creation_turn: int = game.turn.current_turn()
	if (
			data.has("creation_turn")
			and typeof(data["creation_turn"]) in [TYPE_INT, TYPE_FLOAT]
	):
		creation_turn = roundi(data["creation_turn"])
	
	var turns_before_dismiss: int = (
			GameNotification.DEFAULT_TURNS_BEFORE_DISMISS
	)
	if (
			data.has("turns_before_dismiss")
			and typeof(data["turns_before_dismiss"]) in [TYPE_INT, TYPE_FLOAT]
	):
		turns_before_dismiss = roundi(data["turns_before_dismiss"])
	
	var was_seen_this_turn: bool = false
	if (
			data.has("was_seen_this_turn")
			and typeof(data["was_seen_this_turn"]) == TYPE_BOOL
	):
		was_seen_this_turn = data["was_seen_this_turn"]
	
	if not (
			data.has("diplomacy_action_id")
			and typeof(data["diplomacy_action_id"]) in [TYPE_INT, TYPE_FLOAT]
	):
		return GameNotification.new(
				game,
				sender_country,
				recipient_country,
				["OK"],
				[func() -> void: pass]
		)
	
	var action_id: int = roundi(data["diplomacy_action_id"])
	var action: DiplomacyActionDefinition = (
			game.rules.diplomatic_actions.action_from_id(action_id)
	)
	return action.new_notification(
			game,
			sender_country.relationships.with_country(recipient_country),
			recipient_country.relationships.with_country(sender_country),
			creation_turn,
			turns_before_dismiss,
			was_seen_this_turn,
	)
