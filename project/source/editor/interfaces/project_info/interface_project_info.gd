class_name InterfaceProjectInfo
extends AppEditorInterface

signal texture_popup_requested(item_texture: ItemTexture)

var project: GameProject

var _item_project_name := ItemString.new()
var _item_project_icon := ItemTexture.new()

@onready var _game_settings_node := %GameSettingsCategory as ItemVoidNode


func _ready() -> void:
	_item_project_name.text = "Name:"
	_item_project_name.placeholder_text = project.metadata.DEFAULT_PROJECT_NAME
	_item_project_name.value = project.metadata.project_name
	_item_project_name.value_changed.connect(_on_item_name_changed)
	project.metadata.name_changed.connect(_on_project_name_changed)

	_item_project_icon.text = "Icon:"
	_item_project_icon.project_textures = project.textures
	_item_project_icon.fallback_texture = project.metadata.DEFAULT_PROJECT_ICON
	_item_project_icon.popup_requested.connect(texture_popup_requested.emit)
	_item_project_icon.value = _from_metadata_icon(
			project.metadata._icon, project._absolute_file_path
	)
	_item_project_icon.value_changed.connect(_on_item_icon_changed)
	project.metadata.icon_changed.connect(_on_project_icon_changed)

	_game_settings_node.item.child_items = [
		_item_project_name, _item_project_icon
	]
	_game_settings_node.refresh()


func _on_project_name_changed() -> void:
	_item_project_name.value_changed.disconnect(_on_item_name_changed)
	_item_project_name.value = project.metadata.project_name
	_item_project_name.value_changed.connect(_on_item_name_changed)


func _on_project_icon_changed() -> void:
	_item_project_icon.value_changed.disconnect(_on_item_icon_changed)
	_item_project_icon.value = _from_metadata_icon(
			project.metadata._icon, project._absolute_file_path
	)
	_item_project_icon.value_changed.connect(_on_item_icon_changed)


func _on_item_name_changed(_item: PropertyTreeItem) -> void:
	var old_name: String = project.metadata.project_name
	var new_name: String = _item_project_name.value

	undo_redo.create_action("Change project name")
	undo_redo.add_do_property(project.metadata, &"project_name", new_name)
	undo_redo.add_undo_property(project.metadata, &"project_name", old_name)
	undo_redo.commit_action()


func _on_item_icon_changed(_item: PropertyTreeItem) -> void:
	var old_icon: ProjectMetadata.Icon = project.metadata._icon
	var new_icon: ProjectMetadata.Icon = _to_metadata_icon(
			_item_project_icon.value, project._absolute_file_path
	)

	undo_redo.create_action("Change project icon")
	undo_redo.add_do_property(project.metadata, &"_icon", new_icon)
	undo_redo.add_undo_property(project.metadata, &"_icon", old_icon)
	undo_redo.commit_action()


## Converts a metadata's icon into a [ProjectTexture].
static func _from_metadata_icon(
		icon: ProjectMetadata.Icon, project_absolute_path: StringRef
) -> ProjectTexture:
	if icon is ProjectMetadata.IconNone:
		return ProjectTexture.none()
	elif icon is ProjectMetadata.IconInternal:
		return TextureInternal.new(
				(icon as ProjectMetadata.IconInternal)._keyword
		)
	elif icon is ProjectMetadata.IconFromFilePath:
		return TextureFromFilePath.new(
				(icon as ProjectMetadata.IconFromFilePath).relative_path(),
				project_absolute_path
		)
	elif icon is ProjectMetadata.IconFromImageData:
		return TextureFromImageData.new(
				(icon as ProjectMetadata.IconFromImageData)._image_data
		)
	else:
		push_error("Unrecognized metadata icon format.")
		return ProjectTexture.none()


## Converts a [ProjectTexture] into a metadata icon.
static func _to_metadata_icon(
		project_texture: ProjectTexture, project_absolute_path: StringRef
) -> ProjectMetadata.Icon:
	if project_texture is ProjectTexture.TextureNone:
		return ProjectMetadata.Icon.none()
	elif project_texture is TextureInternal:
		return ProjectMetadata.IconInternal.new(
				(project_texture as TextureInternal)._keyword
		)
	elif project_texture is TextureFromFilePath:
		var relative_path: String = FileUtils.path_made_relative(
				project_absolute_path.value,
				(project_texture as TextureFromFilePath).absolute_path()
		)
		return ProjectMetadata.IconFromFilePath.new(
				relative_path, project_absolute_path.value
		)
	elif project_texture is TextureFromImageData:
		return ProjectMetadata.IconFromImageData.new(
				(project_texture as TextureFromImageData)._image_data
		)
	elif project_texture is TextureFromId:
		push_error("Metadata texture is a texture id.")
		return ProjectMetadata.Icon.none()
	else:
		push_error("Unrecognized project texture format.")
		return ProjectMetadata.Icon.none()
