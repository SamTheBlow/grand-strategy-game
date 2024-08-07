class_name GameNotifications
## A list of [GameNotification]s.


signal notification_added(game_notification: GameNotification)
signal notification_removed(game_notification: GameNotification)

var _list: Array[GameNotification] = []


func add(game_notification: GameNotification) -> void:
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


func _remove(game_notification: GameNotification) -> void:
	game_notification.handled.disconnect(_on_notification_handled)
	_list.erase(game_notification)
	notification_removed.emit(game_notification)


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


func _on_notification_handled(game_notification: GameNotification) -> void:
	_remove(game_notification)
