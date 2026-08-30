class_name NotificationInfoPopupFactory
extends Node

signal action_requested(action: Action)

const _NOTIFICATION_INFO_SCENE: PackedScene = preload("uid://crnnhfnswkmub")

@export var _game_node: GameNode
@export var _popup_container: PopupContainer


## Opens a popup with information about some given notification.
func show_notification_info(game_notification: GameNotification) -> void:
	var popup := _NOTIFICATION_INFO_SCENE.instantiate() as NotificationInfoPopup
	popup.game_notification = game_notification
	popup.decision_made.connect(confirm_notification_decision)
	_popup_container.add_popup(popup)


## Requests handling a decision made on a game notification.
func confirm_notification_decision(
		game_notification: GameNotification, outcome_index: int
) -> void:
	if not _game_node.game.turn.is_running():
		return

	# TASK this check shouldn't be here... also DRY: this is a copy/paste
	if not MultiplayerUtils.has_gameplay_authority(
			_game_node.multiplayer, _game_node.game.turn.playing_players()[0]
	):
		push_warning(
				"Tried to handle a game notification, but"
				+ " the user does not have gameplay authority!"
		)
		return

	action_requested.emit(
			ActionHandleNotification.new(game_notification.id, outcome_index)
	)
