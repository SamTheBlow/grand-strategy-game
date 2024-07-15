class_name ActionHandleNotification
extends Action
## Handles given [GameNotification] index with given outcome index.


var _notification_index: int
var _outcome_index: int


func _init(notification_index: int, outcome_index: int) -> void:
	_notification_index = notification_index
	_outcome_index = outcome_index


func apply_to(_game: Game, player: GamePlayer) -> void:
	var game_notification: GameNotification = (
			player.playing_country.notifications
			.from_index(_notification_index)
	)
	
	if game_notification == null:
		push_error(
				"Tried to handle a game notification, but "
				+ "the given notification index is invalid."
		)
		return
	
	game_notification.select_outcome(_outcome_index)


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {
		"id": HANDLE_NOTIFICATION,
		"notification_index": _notification_index,
		"outcome_index": _outcome_index,
	}


## Returns an action built with given raw data.
static func from_raw_data(data: Dictionary) -> ActionHandleNotification:
	return ActionHandleNotification.new(
			data["notification_index"] as int,
			data["outcome_index"] as int
	)
