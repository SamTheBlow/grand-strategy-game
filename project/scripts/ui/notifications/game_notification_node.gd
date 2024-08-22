class_name GameNotificationNode
extends Control
## Displays given [GameNotification] to the user.
##
## Hides itself when game_notification is null.


signal pressed(game_notification: GameNotification)
signal dismissed(game_notification: GameNotification)

var game_notification: GameNotification:
	set(value):
		_disconnect_signals()
		game_notification = value
		_connect_signals()
		_refresh()

@onready var _color_rect := %ColorRect as ColorRect
@onready var _icon := %Icon as TextureRect


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	
	if game_notification == null:
		hide()
		return
	
	if game_notification.has_method("sender_country"):
		_color_rect.color = game_notification.sender_country().color
	else:
		_color_rect.color = Color.WHITE
	
	_icon.texture = game_notification.icon()
	
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


func _on_button_left_click_just_released() -> void:
	pressed.emit(game_notification)


func _on_button_right_click_just_released() -> void:
	dismissed.emit(game_notification)
