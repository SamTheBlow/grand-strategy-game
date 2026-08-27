class_name Lobby
extends Control
## When connected to an online game, hides/disables certain features
## to ensure only the host is able to make changes and start the game.

@onready var _menu_disabled_node := %MenuDisabled as Control
@onready var _start_button := %StartButton as Button


func _ready() -> void:
	_refresh()
	multiplayer.connected_to_server.connect(_refresh)
	multiplayer.server_disconnected.connect(_refresh)


func _refresh() -> void:
	var is_not_authority: bool = not MultiplayerUtils.has_authority(multiplayer)
	_menu_disabled_node.visible = is_not_authority
	_start_button.disabled = is_not_authority
