class_name InterfaceWorldDecoration
extends AppEditorInterface

@onready var _editor_settings_node := %EditorSettingsCategory as ItemVoidNode


func _update_editor_settings() -> void:
	if not is_node_ready():
		return
	_editor_settings_node.item.child_items = [
		editor_settings.show_decorations
	]
	_editor_settings_node.refresh()
