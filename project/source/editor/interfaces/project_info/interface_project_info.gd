class_name InterfaceProjectInfo
extends AppEditorInterface

var _item_project_name := ItemString.new()
var _item_project_icon := ItemTexture.new()


func _ready() -> void:
	_item_project_name.text = "Name:"
	_item_project_name.placeholder_text = project.metadata.DEFAULT_PROJECT_NAME
	_item_project_name.value = project.metadata.project_name
	_item_project_name.value_changed.connect(_on_item_name_changed)
	project.metadata.name_changed.connect(_on_project_name_changed)

	_item_project_icon.text = "Icon:"
	_item_project_icon.fallback_texture = project.metadata.DEFAULT_PROJECT_ICON
	_item_project_icon.popup_requested.connect(
			texture_popup_requested.emit.bind(project.textures)
	)
	_item_project_icon.value = project.metadata.icon
	_item_project_icon.value_changed.connect(_on_item_icon_changed)
	project.metadata.icon_changed.connect(_on_project_icon_changed)

	var game_settings := %GameSettingsCategory as ItemVoidNode
	game_settings.item.child_items = [ _item_project_name, _item_project_icon ]
	game_settings.refresh()

	closed.connect(navigator.close_interface)


func _on_item_name_changed(_item: PropertyTreeItem) -> void:
	var old_name: String = project.metadata.project_name
	var new_name: String = _item_project_name.value

	undo_redo.create_action("Change project name")
	undo_redo.add_do_property(project.metadata, &"project_name", new_name)
	undo_redo.add_undo_property(project.metadata, &"project_name", old_name)
	undo_redo.commit_action()


func _on_item_icon_changed(_item: PropertyTreeItem) -> void:
	var old_icon: ProjectTexture = project.metadata.icon
	var new_icon: ProjectTexture = _item_project_icon.value

	undo_redo.create_action("Change project icon")
	undo_redo.add_do_property(project.metadata, &"icon", new_icon)
	undo_redo.add_undo_property(project.metadata, &"icon", old_icon)
	undo_redo.commit_action()


func _on_project_name_changed() -> void:
	_item_project_name.value_changed.disconnect(_on_item_name_changed)
	_item_project_name.value = project.metadata.project_name
	_item_project_name.value_changed.connect(_on_item_name_changed)


func _on_project_icon_changed() -> void:
	_item_project_icon.value_changed.disconnect(_on_item_icon_changed)
	_item_project_icon.value = project.metadata.icon
	_item_project_icon.value_changed.connect(_on_item_icon_changed)
