class_name ActionHandleNotification
extends Action
## Handles given [GameNotification] index with given outcome index.


const NOTIFICATION_ID_KEY: String = "notification_id"
const OUTCOME_INDEX_KEY: String = "outcome_index"

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


func raw_data() -> Dictionary:
	return {
		ID_KEY: HANDLE_NOTIFICATION,
		NOTIFICATION_ID_KEY: _notification_id,
		OUTCOME_INDEX_KEY: _outcome_index,
	}


static func from_raw_data(data: Dictionary) -> ActionHandleNotification:
	if not (
			ParseUtils.dictionary_has_number(data, NOTIFICATION_ID_KEY)
			and ParseUtils.dictionary_has_number(data, OUTCOME_INDEX_KEY)
	):
		return null
	
	return ActionHandleNotification.new(
			ParseUtils.dictionary_int(data, NOTIFICATION_ID_KEY),
			ParseUtils.dictionary_int(data, OUTCOME_INDEX_KEY)
	)
