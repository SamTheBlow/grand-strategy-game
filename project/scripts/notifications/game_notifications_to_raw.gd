class_name GameNotificationsToRaw
## Converts a [GameNotifications] object into raw data.


func result(game_notifications: GameNotifications) -> Array:
	var output_array: Array = []
	for game_notification in game_notifications._list:
		output_array.append(_game_notification_to_dict(game_notification))
	return output_array


func _game_notification_to_dict(
		game_notification: GameNotification
) -> Dictionary:
	var output: Dictionary = _super_to_dict(game_notification)
	
	var subclass_data: Dictionary = {}
	if game_notification is GameNotificationOffer:
		subclass_data = _offer_to_dict(
				game_notification as GameNotificationOffer
		)
	elif game_notification is GameNotificationOfferAccepted:
		subclass_data = _offer_accepted_to_dict(
				game_notification as GameNotificationOfferAccepted
		)
	elif game_notification is GameNotificationPerformedAction:
		subclass_data = _performed_action_to_dict(
				game_notification as GameNotificationPerformedAction
		)
	
	output.merge(subclass_data)
	return output


func _super_to_dict(game_notification: GameNotification) -> Dictionary:
	var output: Dictionary = {"id": game_notification.id}
	
	if (
			game_notification.creation_turn()
			!= game_notification._game.turn.current_turn()
	):
		output.merge({"creation_turn": game_notification.creation_turn()})
	
	if (
			game_notification._turns_before_dismiss
			!= GameNotification.DEFAULT_TURNS_BEFORE_DISMISS
	):
		output.merge({
				"turns_before_dismiss": game_notification._turns_before_dismiss
		})
	
	if game_notification._was_seen_this_turn:
		output.merge({"was_seen_this_turn": true})
	
	return output


func _offer_to_dict(game_notification: GameNotificationOffer) -> Dictionary:
	return {
		GameNotificationsFromRaw.TYPE_KEY:
			GameNotificationsFromRaw.TYPE_OFFER,
		"sender_country_id": game_notification.sender_country().id,
		"diplomacy_action_id": game_notification.action_id(),
	}


func _offer_accepted_to_dict(
		game_notification: GameNotificationOfferAccepted
) -> Dictionary:
	return {
		GameNotificationsFromRaw.TYPE_KEY:
			GameNotificationsFromRaw.TYPE_OFFER_ACCEPTED,
		"sender_country_id": game_notification.sender_country().id,
		"diplomacy_action_id": game_notification.action_id(),
	}


func _performed_action_to_dict(
		game_notification: GameNotificationPerformedAction
) -> Dictionary:
	return {
		GameNotificationsFromRaw.TYPE_KEY:
			GameNotificationsFromRaw.TYPE_PERFORMED_ACTION,
		"sender_country_id": game_notification.sender_country().id,
		"diplomacy_action_id": game_notification.action_id(),
	}
