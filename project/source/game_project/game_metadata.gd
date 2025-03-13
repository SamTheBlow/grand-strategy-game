class_name GameMetadata
## Data structure.
## Contains a game's metadata, such as its name and its file path.

signal setting_changed(this: GameMetadata)
signal state_updated(this: GameMetadata)

# The keys used in save files
const KEY_METADATA: String = "meta"
const KEY_META_NAME: String = "name"
const KEY_META_ICON: String = "icon"
const KEY_META_SETTINGS: String = "settings"

# The keys used internally for the properties in this class
# TODO 4.2 backwards compatibility: "map_name" will become "project_name"
const KEY_STATE_PROJECT_NAME: String = "map_name"
const KEY_STATE_FILE_PATH: String = "file_path"
const KEY_STATE_ICON: String = "icon"
const KEY_STATE_SETTINGS: String = "settings"

var file_path: String = ""
var project_name: String = "(No name)"
## The project may have no icon, in which case this will be null.
var icon: Texture2D
## Keys must be of type String, values may be any "raw" type.
var settings: Dictionary = {}


## Emits a signal.
## Please use this rather than manually editing the settings property.
func set_setting(key: String, value: Variant) -> void:
	if not ParseUtils.dictionary_has_dictionary(settings, key):
		return
	var setting_dict: Dictionary = settings[key]
	setting_dict[ProjectSettingsNode.KEY_VALUE] = value
	setting_changed.emit(self)


## Returns a new [GameMetadata] instance with data loaded from given file path.
## Returns null if the file could not be loaded.
static func from_file_path(base_path: String) -> GameMetadata:
	var file_json := FileJSON.new()
	file_json.load_json(base_path)
	if file_json.error:
		return null

	return from_raw(file_json.result, base_path)


## Converts given raw data into a new [GameMetadata] instance.
## You still need to provide the file path where the data was located.
static func from_raw(raw_data: Variant, base_path: String) -> GameMetadata:
	var result := GameMetadata.new()
	result.file_path = base_path

	if raw_data is not Dictionary:
		return result
	var raw_dict := raw_data as Dictionary

	if not ParseUtils.dictionary_has_dictionary(raw_dict, KEY_METADATA):
		return result
	var meta_dict := raw_dict[KEY_METADATA] as Dictionary

	if ParseUtils.dictionary_has_string(meta_dict, KEY_META_NAME):
		result.project_name = meta_dict[KEY_META_NAME]

	if ParseUtils.dictionary_has_string(meta_dict, KEY_META_ICON):
		var icon_file_path: String = meta_dict[KEY_META_ICON]
		result.icon = _icon_from_path(base_path, icon_file_path)

	if ParseUtils.dictionary_has_dictionary(meta_dict, KEY_META_SETTINGS):
		# Only load settings whose key is of type String.
		var settings_dict: Dictionary = meta_dict[KEY_META_SETTINGS]
		for key: Variant in settings_dict:
			if key is not String:
				continue
			var key_string := key as String
			result.settings.merge({key_string: settings_dict[key_string]})

	return result


## Returns null if an error occurs.
## The base path is the path in which the project data's file is located.
## The icon's file path is relative to that file path.
static func _icon_from_path(
		base_path: String, icon_file_path: String
) -> Texture2D:
	if base_path == "" or icon_file_path == "":
		return null

	if icon_file_path.is_absolute_path():
		#print_debug(
		#	"Metadata for project icon uses an absolute file path. ",
		#	"Only relative file paths are allowed. Please make sure ",
		#	"the icon's file path is relative to the project's."
		#)
		return null

	var project_dir: DirAccess = DirAccess.open(base_path.get_base_dir())
	project_dir.change_dir(icon_file_path.get_base_dir())
	var true_icon_path: String = (
			project_dir.get_current_dir().path_join(icon_file_path.get_file())
	)
	#print_debug("Loading icon: ", true_icon_path)

	if not ResourceLoader.exists(true_icon_path):
		#print_debug("File for project icon does not exist.")
		return null

	# I'm not sure if this works in 100% of cases but it seems good enough
	if true_icon_path.begins_with("res://"):
		# This is most likely an already imported texture, so load it normally
		return load(true_icon_path) as Texture2D
	else:
		# And here we use this method to load images that aren't yet imported
		return ImageTexture.create_from_image(
				Image.load_from_file(true_icon_path)
		)


## Returns the entire state as a raw Dictionary.
## If include_file_path is set to false, the file path will not be included.
func to_dict(include_file_path: bool = true) -> Dictionary:
	var output := {
		KEY_STATE_PROJECT_NAME: project_name,
		KEY_STATE_SETTINGS: settings,
	}

	if include_file_path:
		output.merge({
			KEY_STATE_FILE_PATH: file_path,
		})

	return output


## Returns a new instance of this object built using given raw Dictionary.
static func from_dict(dict: Dictionary) -> GameMetadata:
	var metadata := GameMetadata.new()

	if ParseUtils.dictionary_has_string(dict, KEY_STATE_PROJECT_NAME):
		metadata.project_name = dict[KEY_STATE_PROJECT_NAME]
	if ParseUtils.dictionary_has_string(dict, KEY_STATE_FILE_PATH):
		metadata.file_path = dict[KEY_STATE_FILE_PATH]
	if ParseUtils.dictionary_has_dictionary(dict, KEY_STATE_SETTINGS):
		metadata.settings = dict[KEY_STATE_SETTINGS]

	return metadata


## Copies the state of this metadata to match the given one.
func copy_state_of(metadata: GameMetadata) -> void:
	project_name = metadata.project_name
	file_path = metadata.file_path
	settings = metadata.settings
	state_updated.emit(self)
