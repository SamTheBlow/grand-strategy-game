class_name ActionHandleNotification
extends Action
## Handles given [GameNotification] index with given outcome index.


var _notification_id: int
var _outcome_index: int


func _init(notification_id: int, outcome_index: int) -> void:
	_notification_id = notification_id
	_outcome_index = outcome_index


func apply_to(game: Game, _player: GamePlayer) -> void:
	var game_notification_: GameNotification = game_notification(game)
	
	if game_notification_ == null:
		push_error(
				"Tried to handle a game notification, but "
				+ "the given notification id is invalid."
				+ " (Id: " + str(_notification_id) + ")"
		)
		return
	
	game_notification_.select_outcome(_outcome_index)


## May return null.
func game_notification(game: Game) -> GameNotification:
	return (
			game.turn.playing_player().playing_country.notifications
			.from_id(_notification_id)
	)


func handles_the_same_notification_as(
		action_handle_notification: ActionHandleNotification
) -> bool:
	return (
			action_handle_notification._notification_id == _notification_id
			if action_handle_notification != null else false
	) 


## Returns this action's raw data, for the purpose of
## transfering between network clients.
func raw_data() -> Dictionary:
	return {
		"id": HANDLE_NOTIFICATION,
		"notification_id": _notification_id,
		"outcome_index": _outcome_index,
	}


## Returns an action built with given raw data.
static func from_raw_data(data: Dictionary) -> ActionHandleNotification:
	return ActionHandleNotification.new(
			data["notification_id"] as int,
			data["outcome_index"] as int
	)
