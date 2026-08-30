class_name NotificationInfoPopupFactory
extends Node
## Opens a popup with information about some given notification.

const _NOTIFICATION_INFO_SCENE: PackedScene = preload("uid://crnnhfnswkmub")

@export var game_node: GameNode
@export var popup_container: PopupContainer


func show_notification_info(game_notification: GameNotification) -> void:
	var popup := _NOTIFICATION_INFO_SCENE.instantiate() as NotificationInfoPopup
	popup.game_notification = game_notification
	popup.decision_made.connect(game_node.confirm_notification_decision)
	popup_container.add_popup(popup)
