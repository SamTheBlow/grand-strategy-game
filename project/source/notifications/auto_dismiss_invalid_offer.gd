class_name AutoDismissInvalidOffer
## Automatically dismisses a [GameNotificationOffer]
## the moment it becomes invalid. That is, when
## the [DiplomacyAction] it represents is no longer available.


var _offer: GameNotificationOffer


func _init(
		offer: GameNotificationOffer, available_actions_changed_signal: Signal
) -> void:
	_offer = offer
	available_actions_changed_signal.connect(_on_available_actions_changed)


func _on_available_actions_changed(relationshp: DiplomacyRelationship) -> void:
	if not relationshp.action_is_available(_offer.action_id()):
		_offer.dismiss()
