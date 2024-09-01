class_name NotificationInfoPopup
extends Control
## Displays information about a certain [GameNotification].
## Allows the user to choose between the
## notification's different outcomes, if applicable.
##
## See also: [GamePopup]


signal decision_made(game_notification: GameNotification, outcome_index: int)

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
	
	_label.text = game_notification.description()


func buttons() -> Array[String]:
	if game_notification.number_of_outcomes() == 0:
		return ["OK"]
	
	var outcome_names: Array[String] = game_notification.outcome_names()
	outcome_names.append("Decide later")
	return outcome_names


func _on_button_pressed(button_index: int) -> void:
	if game_notification == null:
		return
	
	if game_notification.number_of_outcomes() == 0:
		decision_made.emit(game_notification, -1)
		return
	
	var buttons_list: Array[String] = buttons()
	if button_index >= 0 and button_index < buttons_list.size() - 1:
		decision_made.emit(game_notification, button_index)
	elif button_index == buttons_list.size() - 1:
		# "Decide later"
		pass
	else:
		push_warning("Pressed a button with invalid button index.")
