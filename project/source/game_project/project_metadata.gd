class_name ProjectMetadata
## Data structure.
## Contains a project's metadata, such as its name and its file path.

signal setting_changed(this: ProjectMetadata)
signal state_updated(this: ProjectMetadata)

# The keys used in save files
const KEY_METADATA: String = "meta"
const KEY_META_NAME: String = "name"
const KEY_META_ICON: String = "icon"
const KEY_META_SETTINGS: String = "settings"

# The keys used internally for the properties in this class
# TODO 4.2 backwards compatibility: "map_name" will become "name"
const KEY_STATE_FILE_PATH: String = "file_path"
const KEY_STATE_PROJECT_NAME: String = "map_name"
const KEY_STATE_ICON: String = "icon"
const KEY_STATE_SETTINGS: String = "settings"

## The project's absolute file path.
var file_path: String = ""
var project_name: String = "(No name)"
## The project may have no icon, in which case this will be null.
var icon: Texture2D
## Keys must be of type String, values may be any "raw" type.
var settings: Dictionary = {}

# We keep this information to store it in save files
var _icon_file_path: String = ""


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
static func from_file_path(base_path: String) -> ProjectMetadata:
	var file_json := FileJSON.new()
	file_json.load_json(base_path)
	if file_json.error:
		return null

	return from_raw(file_json.result, base_path)


## Converts given raw data into a new [ProjectMetadata] instance.
## You still need to provide the file path where the data was located.
static func from_raw(
		raw_data: Variant, project_absolute_path: String
) -> ProjectMetadata:
	var result := ProjectMetadata.new()
	result.file_path = project_absolute_path

	if raw_data is not Dictionary:
		return result
	var raw_dict := raw_data as Dictionary

	if not ParseUtils.dictionary_has_dictionary(raw_dict, KEY_METADATA):
		return result
	var meta_dict := raw_dict[KEY_METADATA] as Dictionary

	if ParseUtils.dictionary_has_string(meta_dict, KEY_META_NAME):
		result.project_name = meta_dict[KEY_META_NAME]

	if ParseUtils.dictionary_has_string(meta_dict, KEY_META_ICON):
		result._icon_file_path = meta_dict[KEY_META_ICON]
		result.icon = ProjectTexture.texture_from_relative_path(
				project_absolute_path, result._icon_file_path
		)

	if ParseUtils.dictionary_has_dictionary(meta_dict, KEY_META_SETTINGS):
		# Only load settings whose key is of type String.
		var settings_dict: Dictionary = meta_dict[KEY_META_SETTINGS]
		for key: Variant in settings_dict:
			if key is not String:
				continue
			var key_string := key as String
			result.settings.merge({ key_string: settings_dict[key_string] })

	return result


## Returns a dictionary representation of this object meant for save files.
func to_dict_save_file() -> Dictionary:
	var output: Dictionary = {}

	if project_name != "":
		output.merge({ KEY_META_NAME: project_name })

	if _icon_file_path != "":
		output.merge({ KEY_META_ICON: _icon_file_path })

	if not settings.is_empty():
		output.merge({ KEY_META_SETTINGS: settings })

	return output


## Returns the entire state as a raw Dictionary.
## If include_file_path is set to false, the file path will not be included.
func to_dict(include_file_path: bool = true) -> Dictionary:
	var output := {
		KEY_STATE_PROJECT_NAME: project_name,
		KEY_STATE_SETTINGS: settings,
	}

	if include_file_path:
		output.merge({ KEY_STATE_FILE_PATH: file_path })

	return output


## Returns a new instance of this object built using given raw Dictionary.
static func from_dict(raw_dict: Dictionary) -> ProjectMetadata:
	var output := ProjectMetadata.new()
	output.load_from_raw_dict(raw_dict)
	return output


## Updates all internal values to match given raw data.
func load_from_raw_dict(raw_dict: Dictionary) -> void:
	# Use new instance to load default values
	var default_metadata := ProjectMetadata.new()

	if ParseUtils.dictionary_has_string(raw_dict, KEY_STATE_FILE_PATH):
		file_path = raw_dict[KEY_STATE_FILE_PATH]
	else:
		file_path = default_metadata.file_path

	if ParseUtils.dictionary_has_string(raw_dict, KEY_STATE_PROJECT_NAME):
		project_name = raw_dict[KEY_STATE_PROJECT_NAME]
	else:
		project_name = default_metadata.project_name

	if ParseUtils.dictionary_has_dictionary(raw_dict, KEY_STATE_SETTINGS):
		settings = raw_dict[KEY_STATE_SETTINGS]
	else:
		settings = default_metadata.settings

	# TODO parse icon
	icon = null
	_icon_file_path = ""

	state_updated.emit(self)
