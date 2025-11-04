class_name MetadataBundle
## A project's metadata bundled with the project's file path.

const _FILE_PATH_KEY: String = "file_path"
const _META_KEY: String = "meta"

var project_absolute_path: String
var metadata: ProjectMetadata


func _init(
		project_absolute_path_: String = "",
		metadata_ := ProjectMetadata.new()
) -> void:
	project_absolute_path = project_absolute_path_
	metadata = metadata_


## Returns a duplicate of this bundle.
func duplicate() -> MetadataBundle:
	return MetadataBundle.from_raw_data(to_raw_data(true))


static func from_raw_data(raw_data: Variant) -> MetadataBundle:
	var project_path: String = raw_data[_FILE_PATH_KEY]
	var metadata_raw_data: Variant = raw_data[_META_KEY]
	return MetadataBundle.new(
			project_path,
			MetadataParsing.from_raw_data(metadata_raw_data, project_path)
	)


func to_raw_data(include_file_paths: bool) -> Variant:
	var output: Dictionary = {
		_META_KEY: metadata.to_raw_dict(include_file_paths)
	}

	if include_file_paths:
		output.get_or_add(_FILE_PATH_KEY, project_absolute_path)
	else:
		output.get_or_add(_FILE_PATH_KEY, "")

	return output


static func from_path(project_absolute_path_: String) -> ParseResult:
	var new_metadata: ProjectMetadata = (
			ProjectMetadata.from_file_path(project_absolute_path_)
	)
	if new_metadata == null:
		return ResultError.new()

	return ResultSuccess.new(
			MetadataBundle.new(project_absolute_path_, new_metadata)
	)


@abstract class ParseResult:
	var error: bool = false
	var result: MetadataBundle


class ResultError extends ParseResult:
	func _init() -> void:
		error = true


class ResultSuccess extends ParseResult:
	func _init(metadata_bundle: MetadataBundle) -> void:
		result = metadata_bundle
