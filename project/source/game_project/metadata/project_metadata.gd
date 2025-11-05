class_name ProjectMetadata
## Data structure.
## Contains a project's metadata, such as its name and its file path.

signal name_changed()
signal icon_changed()
signal setting_changed(this: ProjectMetadata)
signal state_updated(this: ProjectMetadata)

const DEFAULT_PROJECT_NAME: String = "(Unnamed project)"
const DEFAULT_PROJECT_ICON: Texture2D = preload("uid://dlk4vjy5lgeuu")

var project_name: String = "":
	set(value):
		if project_name == value:
			return
		project_name = value
		name_changed.emit()

## Keys must be of type String, values may be any "raw" type.
var settings: Dictionary = {}

var _icon: Icon = Icon.none():
	set(value):
		if _icon == value:
			return
		_icon = value
		icon_changed.emit()


## Returns the default project name if the current project name is empty.
func project_name_or_default() -> String:
	return project_name if project_name != "" else DEFAULT_PROJECT_NAME


## Returns the project's icon.
func icon() -> Texture2D:
	return _icon.texture if _icon.texture != null else DEFAULT_PROJECT_ICON


func set_project_name(value: String) -> void:
	project_name = value


func set_project_icon(value: Icon) -> void:
	_icon = value


## Emits a signal.
## Please use this rather than manually editing the settings property.
func set_setting(key: String, value: Variant) -> void:
	if not ParseUtils.dictionary_has_dictionary(settings, key):
		return
	var setting_dict: Dictionary = settings[key]
	setting_dict[ProjectSettingsNode.KEY_VALUE] = value
	setting_changed.emit(self)


## Returns a new [ProjectMetadata] instance
## with data loaded from given file path.
## Returns null if the file could not be loaded.
static func from_file_path(project_absolute_path: String) -> ProjectMetadata:
	var file_json := FileJSON.new()
	file_json.load_json(project_absolute_path)
	if file_json.error:
		return null

	return MetadataParsing.from_raw_project_data(
			file_json.result, project_absolute_path
	)


## If include_file_paths is set to true, includes file paths in the output.
## Otherwise, may include different data instead.
func to_raw_dict(include_file_paths: bool) -> Dictionary:
	return MetadataParsing.to_raw_dict(self, include_file_paths)


## Updates all internal values to match given metadata.
func copy_metadata(metadata: ProjectMetadata) -> void:
	project_name = metadata.project_name
	_icon = metadata._icon
	settings = metadata.settings

	state_updated.emit(self)


@abstract class Icon:
	var texture: Texture2D = null

	@abstract func to_raw_data(include_file_paths: bool) -> Variant

	static func none() -> Icon:
		return IconNone.new()


class IconNone extends Icon:
	func to_raw_data(_include_file_paths: bool = false) -> Variant:
		return null


class IconInternal extends Icon:
	var _keyword: String

	func _init(keyword: String) -> void:
		_keyword = keyword
		texture = preload("uid://doda8npdqckhw").texture_with_keyword(_keyword)

	func to_raw_data(_include_file_paths: bool = false) -> Variant:
		return _keyword


class IconFromFilePath extends Icon:
	var _icon_relative_path: String

	func _init(
			icon_relative_path: String, project_absolute_path: String
	) -> void:
		_icon_relative_path = icon_relative_path
		texture = ProjectTextures.texture_from_relative_path(
				project_absolute_path, _icon_relative_path
		)

	func relative_path() -> String:
		return _icon_relative_path

	func to_raw_data(include_file_paths: bool) -> Variant:
		if include_file_paths:
			return _icon_relative_path
		else:
			if texture == null:
				return null
			return Array(TextureFromImageData.to_image_data(texture))


class IconFromImageData extends Icon:
	var _image_data: Array

	func _init(image_data: PackedByteArray) -> void:
		_image_data = Array(image_data)
		texture = TextureFromImageData.from_image_data(image_data)

	func to_raw_data(_include_file_paths: bool = false) -> Variant:
		return _image_data
