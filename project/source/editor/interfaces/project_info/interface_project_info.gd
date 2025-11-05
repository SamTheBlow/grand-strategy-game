class_name InterfaceProjectInfo
extends AppEditorInterface

signal texture_popup_requested(item_texture: ItemTexture)

var _is_setup: bool = false
var _metadata: ProjectMetadata
var _project_absolute_path: StringRef

var _item_project_name := ItemString.new()
var _item_project_icon := ItemTexture.new()

@onready var _container_node: Node = %Container


func _init() -> void:
	_item_project_name.text = "Name:"
	_item_project_name.placeholder_text = _metadata.DEFAULT_PROJECT_NAME
	_item_project_icon.text = "Icon:"
	_item_project_icon.project_textures = ProjectTextures.new(StringRef.new())
	_item_project_icon.fallback_texture = _metadata.DEFAULT_PROJECT_ICON
	_item_project_icon.popup_requested.connect(texture_popup_requested.emit)


func _ready() -> void:
	var project_name_node := (
			preload("uid://cemtdca5rfqlk").instantiate() as ItemStringNode
	)
	project_name_node.item = _item_project_name
	_container_node.add_child(project_name_node)

	var project_icon_node := (
			preload("uid://ccq7n0x7mov6s").instantiate() as ItemTextureNode
	)
	project_icon_node.item = _item_project_icon
	_container_node.add_child(project_icon_node)

	if _is_setup:
		_update()


func setup(
		metadata: ProjectMetadata, project_absolute_path: StringRef
) -> void:
	if _is_setup:
		_metadata.name_changed.disconnect(_update_project_name)
		_metadata.icon_changed.disconnect(_update_project_icon)
	else:
		_item_project_name.value_changed.connect(_set_project_name)
		_item_project_icon.value_changed.connect(_set_project_icon)

	_metadata = metadata
	_project_absolute_path = project_absolute_path
	_is_setup = true

	if is_node_ready():
		_update()


func _update() -> void:
	_update_project_name()
	_update_project_icon()
	_metadata.name_changed.connect(_update_project_name)
	_metadata.icon_changed.connect(_update_project_icon)


func _update_project_name() -> void:
	_item_project_name.value_changed.disconnect(_set_project_name)
	_item_project_name.value = _metadata.project_name
	_item_project_name.value_changed.connect(_set_project_name)


func _update_project_icon() -> void:
	_item_project_icon.value_changed.disconnect(_set_project_icon)
	_item_project_icon.value = (
			_from_metadata_icon(_metadata._icon, _project_absolute_path)
	)
	_item_project_icon.value_changed.connect(_set_project_icon)


func _set_project_name(_item: PropertyTreeItem) -> void:
	undo_redo.create_action("Change project name")
	undo_redo.add_do_method(
			_metadata.set_project_name.bind(_item_project_name.value)
	)
	undo_redo.add_undo_method(
			_metadata.set_project_name.bind(_metadata.project_name)
	)
	undo_redo.commit_action()


func _set_project_icon(_item: PropertyTreeItem) -> void:
	undo_redo.create_action("Change project icon")
	undo_redo.add_do_method(
			_metadata.set_project_icon.bind(_to_metadata_icon(
					_item_project_icon.value, _project_absolute_path
			))
	)
	undo_redo.add_undo_method(
			_metadata.set_project_icon.bind(_metadata._icon)
	)
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
