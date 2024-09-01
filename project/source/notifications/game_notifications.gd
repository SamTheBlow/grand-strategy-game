class_name GameNotifications
## A list of [GameNotification]s.


signal notification_added(game_notification: GameNotification)
signal notification_removed(game_notification: GameNotification)

var _list: Array[GameNotification] = []


func add(game_notification: GameNotification) -> void:
	_remove_duplicates_of(game_notification)
	game_notification.handled.connect(_on_notification_handled)
	_list.append(game_notification)
	notification_added.emit(game_notification)


## Returns a new copy of the list.
func list() -> Array[GameNotification]:
	return _list.duplicate()


## Returns null if there is no notification with given id.
func from_id(id: int) -> GameNotification:
	for game_notification in _list:
		if game_notification.id == id:
			return game_notification
	return null


# TODO DRY. copy/paste from [Players]
## Provides a new unique id that is not used by any item in the list.
## The id will be as small as possible (0 or higher).
func new_unique_id() -> int:
	var new_id: int = 0
	var id_is_not_unique: bool = true
	while id_is_not_unique:
		id_is_not_unique = false
		for element in _list:
			if element.id == new_id:
				id_is_not_unique = true
				new_id += 1
				break
	return new_id


func _remove(game_notification: GameNotification) -> void:
	game_notification.handled.disconnect(_on_notification_handled)
	_list.erase(game_notification)
	notification_removed.emit(game_notification)


func _remove_duplicates_of(game_notification: GameNotification) -> void:
	for element in list():
		if _is_duplicate(element, game_notification):
			_remove(element)


func _is_duplicate(notif_1: GameNotification, notif_2: GameNotification) -> bool:
	if notif_1 is GameNotificationOffer and notif_2 is GameNotificationOffer:
		var offer_1 := notif_1 as GameNotificationOffer
		var offer_2 := notif_2 as GameNotificationOffer
		return (
				offer_1.action_id() == offer_2.action_id()
				and offer_1.sender_country() == offer_2.sender_country()
		)
	elif (
			notif_1 is GameNotificationOfferAccepted
			and notif_2 is GameNotificationOfferAccepted
	):
		var offer_accepted_1 := notif_1 as GameNotificationOfferAccepted
		var offer_accepted_2 := notif_2 as GameNotificationOfferAccepted
		return (
				offer_accepted_1.action_id() == offer_accepted_2.action_id()
				and offer_accepted_1.sender_country()
				== offer_accepted_2.sender_country()
				and offer_accepted_1.creation_turn()
				== offer_accepted_2.creation_turn()
		)
	elif (
			notif_1 is GameNotificationPerformedAction
			and notif_2 is GameNotificationPerformedAction
	):
		var performed_action_1 := notif_1 as GameNotificationPerformedAction
		var performed_action_2 := notif_2 as GameNotificationPerformedAction
		return (
				performed_action_1.action_id() == performed_action_2.action_id()
				and performed_action_1.sender_country()
				== performed_action_2.sender_country()
				and performed_action_1.creation_turn()
				== performed_action_2.creation_turn()
		)
	
	return false


func _on_notification_handled(game_notification: GameNotification) -> void:
	_remove(game_notification)
