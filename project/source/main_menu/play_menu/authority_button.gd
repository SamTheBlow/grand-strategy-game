class_name AuthorityButton
extends Button
## Button that disables itself when connected online and not the host.


func _ready() -> void:
	_refresh()
	multiplayer.connected_to_server.connect(_refresh)
	multiplayer.server_disconnected.connect(_refresh)


func _refresh() -> void:
	disabled = not MultiplayerUtils.has_authority(multiplayer)
