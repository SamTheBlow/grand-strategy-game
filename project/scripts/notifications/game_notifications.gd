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


## If given index is out of bounds, returns null.
func from_index(index: int) -> GameNotification:
	if index < 0 or index >= _list.size():
		return null
	return _list[index]


func _remove(game_notification: GameNotification) -> void:
	game_notification.handled.disconnect(_on_notification_handled)
	_list.erase(game_notification)
	notification_removed.emit(game_notification)


func _on_notification_handled(game_notification: GameNotification) -> void:
	_remove(game_notification)
