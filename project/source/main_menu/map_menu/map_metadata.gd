class_name MapMetadata
## Data structure. Contains a game map's metadata.


signal setting_changed(this: MapMetadata)
signal state_updated(this: MapMetadata)

# The keys used in save files
const KEY_METADATA: String = "meta"
const KEY_META_NAME: String = "name"
const KEY_META_ICON: String = "icon"
const KEY_META_SETTINGS: String = "settings"

# The keys used internally for the properties in this class
const KEY_STATE_MAP_NAME: String = "map_name"
const KEY_STATE_FILE_PATH: String = "file_path"
const KEY_STATE_ICON: String = "icon"
const KEY_STATE_SETTINGS: String = "settings"

var map_name: String = ""
var file_path: String = ""
## The map may have no icon, in which case this will be null.
var icon: Texture2D
## Keys must be of type String, values may be any "raw" type.
var settings: Dictionary = {}


## Emits a signal.
## Please use this rather than manually editing the settings property.
func set_setting(key: String, value: Variant) -> void:
	if not ParseUtils.dictionary_has_dictionary(settings, key):
		return
	var setting_dict: Dictionary = settings[key]
	setting_dict[MapSettings.KEY_VALUE] = value
	setting_changed.emit(self)


## Returns a new MapMetadata instance with data loaded from given file path.
## You still have to assign it an ID manually, however.
## This may return null if an error occurs, e.g. the file's contents are invalid.
static func from_file_path(base_path: String) -> MapMetadata:
	var file_json := FileJSON.new()
	file_json.load_json(base_path)
	if file_json.error:
		#print_debug("Failed to load map JSON: ", file_json.error_message)
		return null
	var json_data: Variant = file_json.result
	if json_data is not Dictionary:
		#print_debug("Can't load map metadata: JSON data is not a Dictionary")
		return null
	var json_dict := json_data as Dictionary
	if not ParseUtils.dictionary_has_dictionary(json_dict, KEY_METADATA):
		return null
	var meta_dict := json_dict[KEY_METADATA] as Dictionary
	
	var result := MapMetadata.new()
	result.file_path = base_path
	
	if ParseUtils.dictionary_has_string(meta_dict, KEY_META_NAME):
		result.map_name = meta_dict[KEY_META_NAME]
	else:
		result.map_name = "(No name)"
	
	if ParseUtils.dictionary_has_string(meta_dict, KEY_META_ICON):
		var map_icon_file_path: String = meta_dict[KEY_META_ICON]
		result.icon = _map_icon_from_path(base_path, map_icon_file_path)
	
	if ParseUtils.dictionary_has_dictionary(meta_dict, KEY_META_SETTINGS):
		# Only load settings whose key is of type String.
		var settings_dict: Dictionary = meta_dict[KEY_META_SETTINGS]
		for key: Variant in settings_dict.keys():
			if key is not String:
				continue
			var key_string := key as String
			result.settings.merge({key_string: settings_dict[key_string]})
	
	return result


## Returns null if an error occurs.
## The base path is the path in which the map data's file is located.
## The icon's file path is relative to that file path.
static func _map_icon_from_path(
		base_path: String, icon_file_path: String
) -> Texture2D:
	if icon_file_path.is_absolute_path():
		#push_error(
		#	"Metadata for map icon uses an absolute file path. ",
		#	"Only relative file paths are allowed. ",
		#	"Please make sure the icon's file path is relative to the map's."
		#)
		return null
	
	var map_dir: DirAccess = DirAccess.open(base_path.get_base_dir())
	if not map_dir.file_exists(icon_file_path):
		#push_error("File for map icon does not exist.")
		return null
	
	map_dir.change_dir(icon_file_path.get_base_dir())
	var true_icon_path: String = (
			map_dir.get_current_dir().path_join(icon_file_path.get_file())
	)
	#print_debug("Loading icon: ", true_icon_path)
	
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
		KEY_STATE_MAP_NAME: map_name,
		KEY_STATE_SETTINGS: settings,
	}
	
	if include_file_path:
		output.merge({
			KEY_STATE_FILE_PATH: file_path,
		})
	
	return output


## Returns a new instance of this object built using given raw Dictionary.
static func from_dict(dict: Dictionary) -> MapMetadata:
	var new_map_data := MapMetadata.new()
	
	if ParseUtils.dictionary_has_string(dict, KEY_STATE_MAP_NAME):
		new_map_data.map_name = dict[KEY_STATE_MAP_NAME]
	if ParseUtils.dictionary_has_string(dict, KEY_STATE_FILE_PATH):
		new_map_data.file_path = dict[KEY_STATE_FILE_PATH]
	if ParseUtils.dictionary_has_dictionary(dict, KEY_STATE_SETTINGS):
		new_map_data.settings = dict[KEY_STATE_SETTINGS]
	
	return new_map_data


## Copies the state of this metadata to match the given one.
func copy_state_of(map_metadata: MapMetadata) -> void:
	map_name = map_metadata.map_name
	file_path = map_metadata.file_path
	settings = map_metadata.settings
	state_updated.emit(self)
