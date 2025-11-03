class_name ProjectTextureParsing
## Parses raw data from/to [ProjectTextures].

const _ID_KEY: String = "id"
const _FILE_PATH_KEY: String = "file_path"
const _RAW_IMAGE_DATA_KEY: String = "raw_image_data"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(
		raw_data: Variant, project_absolute_path: StringRef
) -> ProjectTextures:
	var project_textures := ProjectTextures.new(project_absolute_path)

	if raw_data is not Array:
		return project_textures
	var raw_array: Array = raw_data

	for texture_data: Variant in raw_array:
		_load_texture_from_raw_data(texture_data, project_textures)

	return project_textures


## If use_file_path is true, the data contains file paths.
## Otherwise, the data contains raw image data instead.
static func to_raw_array(
		project_textures: ProjectTextures, use_file_paths: bool
) -> Array:
	var output: Array = []

	# Start by adding the textures that have a file path.
	var already_added_ids: Array[int] = []
	for absolute_file_path in project_textures._file_map:
		var id: int = project_textures._file_map[absolute_file_path]
		if already_added_ids.has(id):
			continue

		if use_file_paths:
			var relative_path: String = FileUtils.path_made_relative(
					project_textures.project_absolute_path_ref().value,
					absolute_file_path
			)
			if not relative_path.is_empty():
				output.append({ _ID_KEY: id, _FILE_PATH_KEY: relative_path })
		else:
			var image_data := Array(TextureFromImageData.to_image_data(
					project_textures._id_map[id]
			))
			if not image_data.is_empty():
				output.append(
						{ _ID_KEY: id, _RAW_IMAGE_DATA_KEY: image_data }
				)

		already_added_ids.append(id)

	# Now add the textures that don't have a file path.
	for id in project_textures._id_map:
		if already_added_ids.has(id):
			continue

		if use_file_paths:
			# TODO save the texture to a new file path
			var relative_path: String = ""
			if not relative_path.is_empty():
				output.append({ _ID_KEY: id, _FILE_PATH_KEY: relative_path })
		else:
			var image_data := Array(TextureFromImageData.to_image_data(
					project_textures._id_map[id]
			))
			if not image_data.is_empty():
				output.append(
						{ _ID_KEY: id, _RAW_IMAGE_DATA_KEY: image_data }
				)

	return output


static func _load_texture_from_raw_data(
		raw_data: Variant, project_textures: ProjectTextures
) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	# Id (mandatory)
	if not ParseUtils.dictionary_has_number(raw_dict, _ID_KEY):
		return
	var id: int = ParseUtils.dictionary_int(raw_dict, _ID_KEY)
	if id < 0 or project_textures._id_map.has(id):
		return

	# File path (has priority over raw image data)
	#
	# Special case: if the file path is an empty string,
	# act as if no file path was provided.
	if (
			ParseUtils.dictionary_has_string(raw_dict, _FILE_PATH_KEY)
			and not raw_dict[_FILE_PATH_KEY].is_empty()
	):
		var absolute_path: String = ProjectTextures.texture_path_made_absolute(
				project_textures.project_absolute_path_ref().value,
				raw_dict[_FILE_PATH_KEY]
		)
		project_textures.claim_id_with_file_path(id, absolute_path)

	# Raw image data
	#
	# Special case: if the image data is an empty array,
	# act as if no image data was provided.
	elif (
			ParseUtils.dictionary_has_array(raw_dict, _RAW_IMAGE_DATA_KEY)
			and not raw_dict[_RAW_IMAGE_DATA_KEY].is_empty()
	):
		var raw_image_data := PackedByteArray(raw_dict[_RAW_IMAGE_DATA_KEY])
		project_textures.claim_id_with_image_data(id, raw_image_data)

	# We didn't find either. Claim the id anyway.
	else:
		project_textures.claim_id(id)
