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

var icon: ProjectTexture = ProjectTexture.none():
	set(value):
		if icon == value:
			return
		icon = value
		icon_changed.emit()

## Keys must be of type String, values may be any "raw" type.
var settings: Dictionary = {}


## Returns the default project name if the current project name is empty.
func project_name_or_default() -> String:
	return project_name if project_name != "" else DEFAULT_PROJECT_NAME


## Returns the project's icon texture, with default icon fallback.
func icon_texture() -> Texture2D:
	return icon.texture(DEFAULT_PROJECT_ICON)


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
	icon = metadata.icon
	settings = metadata.settings

	state_updated.emit(self)
