class_name GameNotificationsNode
extends Control
## Displays all [GameNotification]s of given [GamePlayer]'s playing country.
## Updates itself when new notifications are received.


signal pressed(game_notification: GameNotification)
signal dismissed(game_notification: GameNotification)

@export var game_notification_scene: PackedScene

var game_player: GamePlayer:
	set(value):
		game_player = value
		
		if game_player == null:
			_game_notifications = null
			return
		
		_game_notifications = game_player.playing_country.notifications

var _game_notifications: GameNotifications:
	set(value):
		if _game_notifications == value:
			return
		_disconnect_signals()
		_game_notifications = value
		_connect_signals()
		_refresh()

@onready var _container := %ListContainer as ListContainer


func _ready() -> void:
	_refresh()


func _refresh() -> void:
	if not is_node_ready():
		return
	
	NodeUtils.delete_all_children(_container)
	
	if _game_notifications == null:
		return
	
	for game_notification in _game_notifications.list():
		_add_notification_node(game_notification)


func _add_notification_node(game_notification: GameNotification) -> void:
	var game_notification_node := (
			game_notification_scene.instantiate() as GameNotificationNode
	)
	game_notification_node.game_notification = game_notification
	game_notification_node.pressed.connect(_on_notification_pressed)
	game_notification_node.dismissed.connect(_on_notification_dismissed)
	_container.add_child(game_notification_node)


func _connect_signals() -> void:
	if _game_notifications == null:
		return
	
	if not _game_notifications.notification_added.is_connected(
			_on_notification_added
	):
		_game_notifications.notification_added.connect(
				_on_notification_added
		)


func _disconnect_signals() -> void:
	if _game_notifications == null:
		return
	
	if _game_notifications.notification_added.is_connected(
			_on_notification_added
	):
		_game_notifications.notification_added.disconnect(
				_on_notification_added
		)


func _on_notification_added(game_notification: GameNotification) -> void:
	# WARNING This assumes that [GameNotifications] always appends
	# new notifications at the end of its list. Were that not the case,
	# this could potentially add nodes in the wrong order.
	_add_notification_node(game_notification)


func _on_notification_pressed(game_notification: GameNotification) -> void:
	pressed.emit(game_notification)


func _on_notification_dismissed(game_notification: GameNotification) -> void:
	dismissed.emit(game_notification)
