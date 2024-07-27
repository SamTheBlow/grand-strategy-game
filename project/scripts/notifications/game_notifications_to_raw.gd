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
	var output: Dictionary = {
		"sender_country_id": game_notification._sender_country.id,
		"creation_turn": game_notification._creation_turn,
		"turns_before_dismiss": game_notification._turns_before_dismiss,
		"was_seen_this_turn": game_notification._was_seen_this_turn,
	}
	
	var diplomacy_action_id: int = -1
	var diplomacy_action_definition: DiplomacyActionDefinition = (
			game_notification.diplomacy_action_definition
	)
	if diplomacy_action_definition != null:
		diplomacy_action_id = diplomacy_action_definition.id
	if diplomacy_action_id >= 0:
		output["diplomacy_action_id"] = diplomacy_action_id
	
	return output
