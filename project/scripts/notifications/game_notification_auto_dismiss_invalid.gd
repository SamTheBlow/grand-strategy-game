class_name GameNotificationAutoDismissInvalid
## Automatically dismisses a [GameNotification] the moment it becomes invalid.
## That is, when the [DiplomacyAction] it represents is no longer available.


var _game_notification: GameNotification


func _init(
		game_notification: GameNotification,
		available_actions_changed_signal: Signal
) -> void:
	_game_notification = game_notification
	available_actions_changed_signal.connect(_on_available_actions_changed)


func _on_available_actions_changed(relationshp: DiplomacyRelationship) -> void:
	if _game_notification == null:
		return
	
	if not relationshp.action_is_available(
			_game_notification.diplomacy_action_definition.id
	):
		_game_notification.dismiss()
