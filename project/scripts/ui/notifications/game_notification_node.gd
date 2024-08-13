class_name GameNotificationNode
extends Control
## Visual representation of a [GameNotification].
##
## Note: this node hides itself when game_notification is null.


signal pressed(game_notification: GameNotification)
signal dismissed(game_notification: GameNotification)

var game_notification: GameNotification:
	set(value):
		_disconnect_signals()
		game_notification = value
		_connect_signals()
		_refresh()

@onready var _color_rect := %ColorRect as ColorRect


func _ready() -> void:
	_refresh()


# TODO Find a better solution. This doesn't 100% work.
# Like, if a different unrelated event happens on the same frame,
# the action will go through anyway (try spamming any keyboard key
# while spamming right click on the notification)
func _unhandled_input(_event: InputEvent) -> void:
	if (
			game_notification != null
			and Input.is_action_just_pressed("dismiss_notification")
			and
			get_global_rect().has_point(get_viewport().get_mouse_position())
	):
		dismissed.emit(game_notification)
		get_viewport().set_input_as_handled()


func _refresh() -> void:
	if not is_node_ready():
		return
	
	if game_notification == null:
		hide()
		return
	
	_color_rect.color = game_notification.sender_country().color
	show()


func _disconnect_signals() -> void:
	if game_notification == null:
		return
	
	if game_notification.handled.is_connected(_on_notification_handled):
		game_notification.handled.disconnect(_on_notification_handled)


func _connect_signals() -> void:
	if game_notification == null:
		return
	
	if not game_notification.handled.is_connected(_on_notification_handled):
		game_notification.handled.connect(_on_notification_handled)


func _on_notification_handled(_game_notification: GameNotification) -> void:
	queue_free()


func _on_button_pressed() -> void:
	pressed.emit(game_notification)
