class_name MetadataParsing
## Parses raw data from/to a [ProjectMetadata] instance.

const _NAME_KEY: String = "name"
const _ICON_KEY: String = "icon"
const _SETTINGS_KEY: String = "settings"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_project_data(
		project_raw_data: Variant, project_absolute_path: String
) -> ProjectMetadata:
	if project_raw_data is not Dictionary:
		return ProjectMetadata.new()
	var project_raw_dict: Dictionary = project_raw_data

	if not project_raw_dict.has(ProjectParsing.METADATA_KEY):
		return ProjectMetadata.new()

	return from_raw_data(
			project_raw_dict[ProjectParsing.METADATA_KEY],
			project_absolute_path
	)


## NOTE: We need the project's file path in order to load the icon properly.
##
## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(
		raw_data: Variant, project_absolute_path: String
) -> ProjectMetadata:
	var output := ProjectMetadata.new()

	if raw_data is not Dictionary:
		return output
	var raw_dict: Dictionary = raw_data

	# Project name
	if ParseUtils.dictionary_has_string(raw_dict, _NAME_KEY):
		output.project_name = raw_dict[_NAME_KEY]

	# Project icon
	if ParseUtils.dictionary_has_string(raw_dict, _ICON_KEY):
		var icon_string: String = raw_dict[_ICON_KEY]

		# Internal resource
		if icon_string.begins_with(ExposedResources.INTERNAL_PREFIX):
			output._icon = ProjectMetadata.IconInternal.new(icon_string)
		
		# File path
		else:
			output._icon = ProjectMetadata.IconFromFilePath.new(
					icon_string, project_absolute_path
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
