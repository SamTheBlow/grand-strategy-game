class_name InterfaceWorldLimits
extends AppEditorInterface

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode
@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode


func _update_editor_settings() -> void:
	if not is_node_ready():
		return
	_editor_settings_node.item.child_items = [
		editor_settings.show_world_limits
	]
	_editor_settings_node.refresh()


func _update_game_settings() -> void:
	if not is_node_ready():
		return
	_game_settings_node.item.child_items = [
		game_settings.custom_world_limits_enabled
	]
	_game_settings_node.refresh()
