class_name GameNotifications
## A list of [GameNotification]s.

signal notification_added(game_notification: GameNotification)
signal notification_removed(game_notification: GameNotification)

var _list: Array[GameNotification] = []
var _unique_id_system := UniqueIdSystem.new()


## Note that this overwrites the notification's id.
## If you want it to use a specific id, pass it as an argument.
##
## An error will occur if given id is not available.
## Use is_id_available first to verify (see [UniqueIdSystem]).
func add(game_notification: GameNotification, specific_id: int = -1) -> void:
	_remove_duplicates_of(game_notification)

	var id: int = specific_id
	if not _unique_id_system.is_id_valid(specific_id):
		id = _unique_id_system.new_unique_id()
	elif not _unique_id_system.is_id_available(specific_id):
		push_error(
				"Specified GameNotification id is not unique."
				+ " (id: " + str(specific_id) + ")"
		)
		id = _unique_id_system.new_unique_id()
	else:
		_unique_id_system.claim_id(specific_id)

	game_notification.id = id
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


func id_system() -> UniqueIdSystem:
	return _unique_id_system


func _remove(game_notification: GameNotification) -> void:
	game_notification.handled.disconnect(_on_notification_handled)
	_list.erase(game_notification)
	notification_removed.emit(game_notification)


func _remove_duplicates_of(game_notification: GameNotification) -> void:
	for element in list():
		if _is_duplicate(element, game_notification):
			_remove(element)


func _is_duplicate(
		notif_1: GameNotification, notif_2: GameNotification
) -> bool:
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
