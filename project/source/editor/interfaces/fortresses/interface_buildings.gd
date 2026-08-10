class_name InterfaceFortressSettings
extends AppEditorInterface
## The interface in which the user can edit the fortress settings.
## These settings are not yet synchronized with the project data,
## so editing them currently has no effect on the game.


func _ready() -> void:
	var editor_settings_node := %EditorSettings as ItemVoidNode
	editor_settings_node.item.child_items = [
		editor_settings.show_buildings
	]
	editor_settings_node.refresh()

	closed.connect(navigator.close_interface)
