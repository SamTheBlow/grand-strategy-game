class_name MetadataParsing
## Parses raw data from/to a [ProjectMetadata] instance.

const _FILE_PATH_KEY: String = "file_path"
const _NAME_KEY: String = "name"
const _ICON_KEY: String = "icon"
const _SETTINGS_KEY: String = "settings"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_project_data(
		project_raw_data: Variant, project_absolute_path := StringRef.new()
) -> ProjectMetadata:
	if project_raw_data is not Dictionary:
		var output := ProjectMetadata.new()
		output.project_absolute_path = project_absolute_path
		return output
	var project_raw_dict: Dictionary = project_raw_data

	if not project_raw_dict.has(ProjectParsing.METADATA_KEY):
		var output := ProjectMetadata.new()
		output.project_absolute_path = project_absolute_path
		return output

	return from_raw_data(
			project_raw_dict[ProjectParsing.METADATA_KEY],
			project_absolute_path
	)


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(
		raw_data: Variant, project_absolute_path := StringRef.new()
) -> ProjectMetadata:
	var output := ProjectMetadata.new()
	output.project_absolute_path = project_absolute_path

	if raw_data is not Dictionary:
		return output
	var raw_dict: Dictionary = raw_data

	# Project absolute file path
	if ParseUtils.dictionary_has_string(raw_dict, _FILE_PATH_KEY):
		output.project_absolute_path.value = raw_dict[_FILE_PATH_KEY]

	# Project name
	if ParseUtils.dictionary_has_string(raw_dict, _NAME_KEY):
		output.project_name = raw_dict[_NAME_KEY]

	# Project icon
	if ParseUtils.dictionary_has_string(raw_dict, _ICON_KEY):
		# File path
		var file_path: String = raw_dict[_ICON_KEY]
		output._icon = ProjectMetadata.IconFromFilePath.new(
				file_path, project_absolute_path
		)
	elif ParseUtils.dictionary_has_array(raw_dict, _ICON_KEY):
		# Image data
		var image_data := PackedByteArray(raw_dict[_ICON_KEY])
		output._icon = ProjectMetadata.IconFromImageData.new(image_data)

	# Custom settings
	if ParseUtils.dictionary_has_dictionary(raw_dict, _SETTINGS_KEY):
		# Only load settings whose key is of type String.
		var settings_dict: Dictionary = raw_dict[_SETTINGS_KEY]
		for key: Variant in settings_dict:
			if key is not String:
				continue
			var key_string := key as String
			output.settings.merge({ key_string: settings_dict[key_string] })

	return output


## If include_file_paths is set to true, includes file paths in the output.
## Otherwise, may include different data instead.
static func to_raw_dict(
		metadata: ProjectMetadata, include_file_paths: bool
) -> Dictionary:
	var output: Dictionary = {}

	if include_file_paths and metadata.project_absolute_path.value != "":
		output.get_or_add(_FILE_PATH_KEY, metadata.project_absolute_path.value)

	if metadata.project_name != "":
		output.get_or_add(_NAME_KEY, metadata.project_name)

	var icon_raw_data: Variant = metadata._icon.to_raw_data(include_file_paths)
	if not (
			icon_raw_data == null
			or is_same(icon_raw_data, "")
			or ParseUtils.is_empty_array(icon_raw_data)
	):
		output.get_or_add(_ICON_KEY, icon_raw_data)

	if not metadata.settings.is_empty():
		output.get_or_add(_SETTINGS_KEY, metadata.settings)

	return output
