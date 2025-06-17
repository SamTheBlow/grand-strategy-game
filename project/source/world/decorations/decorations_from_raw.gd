class_name WorldDecorationsFromRaw
## Converts raw data into [WorldDecoration]s.
##
## See also: [WorldDecorationsToRaw]

const TEXTURE_FILE_PATH_KEY: String = "texture"
const FLIP_H_KEY: String = "flip_h"
const FLIP_V_KEY: String = "flip_v"
const POSITION_KEY: String = "position"
const ROTATION_KEY: String = "rotation"
const SCALE_KEY: String = "scale"
const COLOR_KEY: String = "color"


static func parsed_from(
		raw_data: Variant, project_file_path: String
) -> ParseResult:
	var output := ParseResult.new()

	if raw_data is not Array:
		return output
	var raw_array: Array = raw_data

	for raw_decoration: Variant in raw_array:
		var parse_result: ParseResult = _decoration_from_raw(
				raw_decoration, project_file_path
		)
		output.invalid_file_paths.append_array(parse_result.invalid_file_paths)
		output.decorations.append_array(parse_result.decorations)

	return output


## Converts raw data into a [WorldDecoration].
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func _decoration_from_raw(
		raw_data: Variant, project_file_path: String
) -> ParseResult:
	var output := ParseResult.new()

	if raw_data is not Dictionary:
		return output
	var raw_dict: Dictionary = raw_data

	var decoration := WorldDecoration.new()

	if ParseUtils.dictionary_has_string(raw_dict, TEXTURE_FILE_PATH_KEY):
		decoration.texture_file_path = raw_dict[TEXTURE_FILE_PATH_KEY]
		decoration.texture = GameMetadata.project_texture(
				project_file_path, decoration.texture_file_path
		)

	if decoration.texture == null:
		output.invalid_file_paths = [decoration.texture_file_path]
		return output

	if ParseUtils.dictionary_has_bool(raw_dict, FLIP_H_KEY):
		decoration.flip_h = raw_dict[FLIP_H_KEY]

	if ParseUtils.dictionary_has_bool(raw_dict, FLIP_V_KEY):
		decoration.flip_v = raw_dict[FLIP_V_KEY]

	if ParseUtils.dictionary_has_dictionary(raw_dict, POSITION_KEY):
		var position_dict: Dictionary = raw_dict[POSITION_KEY]
		if ParseUtils.dictionary_has_number(position_dict, "x"):
			decoration.position.x = (
					ParseUtils.number_as_float(position_dict["x"])
			)
		if ParseUtils.dictionary_has_number(position_dict, "y"):
			decoration.position.y = (
					ParseUtils.number_as_float(position_dict["y"])
			)

	# The rotation is in degrees.
	if ParseUtils.dictionary_has_number(raw_dict, ROTATION_KEY):
		decoration.rotation_degrees = (
				ParseUtils.number_as_float(raw_dict[ROTATION_KEY])
		)

	# The scale can be either one number, or a set of x and y.
	if ParseUtils.dictionary_has_number(raw_dict, SCALE_KEY):
		decoration.scale = (
				Vector2.ONE * ParseUtils.number_as_float(raw_dict[SCALE_KEY])
		)
	elif ParseUtils.dictionary_has_dictionary(raw_dict, SCALE_KEY):
		var scale_dict: Dictionary = raw_dict[SCALE_KEY]
		if ParseUtils.dictionary_has_number(scale_dict, "x"):
			decoration.scale.x = ParseUtils.number_as_float(scale_dict["x"])
		if ParseUtils.dictionary_has_number(scale_dict, "y"):
			decoration.scale.y = ParseUtils.number_as_float(scale_dict["y"])

	if raw_dict.has(COLOR_KEY):
		decoration.color = ParseUtils.color_from_raw(
				raw_dict[COLOR_KEY], decoration.color
		)

	output.decorations = [decoration]
	return output


## There may be any number of invalid decorations, and valid decorations.
## If there are 0 valid and 0 invalid,
## then it means there was an error and decorations could not be parsed.
class ParseResult:
	# Decorations are not created when their texture could not be obtained.
	# Instead, the texture's file path is stored here.
	# Useful to inform the user that these files could not be loaded.
	# The same file path may appear more than once.
	var invalid_file_paths: Array[String] = []

	var decorations: Array[WorldDecoration] = []
