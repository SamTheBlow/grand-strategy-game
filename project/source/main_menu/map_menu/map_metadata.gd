class_name MapMetadata
## Data structure. Contains a game map's metadata.


const KEY_METADATA: String = "meta"
const KEY_META_NAME: String = "name"
const KEY_META_ICON: String = "icon"

var id: int = -1
var map_name: String = ""
var file_path: String = ""
## The map may have no icon, in which case this will be null.
var icon: Texture2D


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
		"id": id,
		"map_name": map_name,
	}
	
	if include_file_path:
		output.merge({
			"file_path": file_path,
		})
	
	return output


## Returns a new instance of this object built using given raw Dictionary.
static func from_dict(dict: Dictionary) -> MapMetadata:
	var new_map_data := MapMetadata.new()
	
	if ParseUtils.dictionary_has_number(dict, "id"):
		new_map_data.id = ParseUtils.dictionary_int(dict, "id")
	if ParseUtils.dictionary_has_string(dict, "map_name"):
		new_map_data.map_name = dict["map_name"]
	if ParseUtils.dictionary_has_string(dict, "file_path"):
		new_map_data.file_path = dict["file_path"]
	
	return new_map_data
