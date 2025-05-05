class_name InterfaceBackgroundColor
extends AppEditorInterface

@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode


func _update_game_settings() -> void:
	if not is_node_ready():
		return
	_game_settings_node.item.child_items = [
		game_settings.background_color
	]
	_game_settings_node.refresh()
