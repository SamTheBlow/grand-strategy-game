class_name ProjectTextureParsing
## Converts [ProjectTexture]s from/to raw data.

const ID_KEY: String = "id"
const FILE_PATH_KEY: String = "file_path"
const RAW_IMAGE_DATA_KEY: String = "raw_image_data"


## Returns a new [ProjectTextures] using given raw data.
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func textures_from_raw_data(raw_data: Variant) -> ProjectTextures:
	var project_textures := ProjectTextures.new()

	if raw_data is not Array:
		return project_textures
	var raw_array: Array = raw_data

	for texture_data: Variant in raw_array:
		_add_texture_from_raw(texture_data, project_textures)

	return project_textures


## Converts given [ProjectTextures] into raw data.
## If use_file_path is true, the data contains file paths.
## Otherwise, the data contains raw image data instead.
static func textures_to_raw_array(
		project_textures: ProjectTextures, use_file_paths: bool
) -> Array:
	var output: Array = []
	for texture: ProjectTexture in project_textures._id_map.values():
		output.append(texture_to_raw_dictionary(texture, use_file_paths))
	return output


## Converts raw data into a new [ProjectTexture] and adds it to given list.
## No effect if the data is invalid
## (it must be a dictionary with a valid id inside).
static func _add_texture_from_raw(
		raw_data: Variant, project_textures: ProjectTextures
) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, ID_KEY):
		return
	var id: int = ParseUtils.dictionary_int(raw_dict, ID_KEY)

	# If there's no file path and no raw image data, use the default texture
	var new_project_texture := ProjectTexture.new()
	new_project_texture.id = id

	# File path (optional, has priority over raw image data)
	if ParseUtils.dictionary_has_string(raw_dict, FILE_PATH_KEY):
		var file_path: String = raw_dict[FILE_PATH_KEY]
		var texture_from_path: ProjectTexture = (
				project_textures.texture_from_file_path(file_path)
		)
		if texture_from_path != null:
			# We've already loaded this image before.
			# Avoid loading it again
			new_project_texture.texture = texture_from_path.texture
			new_project_texture._file_path = file_path
		else:
			new_project_texture.load_texture_from_path(file_path)

	# Raw image data (optional)
	elif ParseUtils.dictionary_has_array(raw_dict, RAW_IMAGE_DATA_KEY):
		var raw_image_data := PackedByteArray(raw_dict[RAW_IMAGE_DATA_KEY])
		new_project_texture.load_texture_from_data(raw_image_data)

	project_textures.add(new_project_texture)


## Returns given [ProjectTexture] as raw data.
## If use_file_path is true, the data contains a file path.
## Otherwise, the data contains raw image data instead.
static func texture_to_raw_dictionary(
		project_texture: ProjectTexture, use_file_path: bool
) -> Dictionary:
	var output: Dictionary = { ID_KEY: project_texture.id }
	if use_file_path:
		output.merge({ FILE_PATH_KEY: project_texture._file_path })
	else:
		output.merge({
			RAW_IMAGE_DATA_KEY: Array(project_texture.texture_data())
		})
	return output
