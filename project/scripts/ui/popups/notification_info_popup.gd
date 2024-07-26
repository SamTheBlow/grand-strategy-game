class_name NotificationInfoPopup
extends Control


var game_notification: GameNotification:
	set(value):
		game_notification = value
		_refresh()

@onready var _label := %Label as Label


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready() or game_notification == null:
		return
	
	_label.text = (
			game_notification.sender_country().country_name
			+ ' has made this request: "'
			+ game_notification.diplomacy_action_definition.name + '"'
	)


func buttons() -> Array[String]:
	return ["Accept", "Decline", "Decide later"]


func _on_button_pressed(button_index: int) -> void:
	if game_notification == null:
		return
	
	match button_index:
		0:
			game_notification.select_outcome(0)
		1:
			game_notification.dismiss()
		2:
			pass
		_:
			push_warning("Unrecognized button index.")
