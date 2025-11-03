class_name WorldDecorationParsing
## Parses raw data from/to [WorldDecorations].

const _TEXTURE_KEY: String = "texture"
const _FLIP_H_KEY: String = "flip_h"
const _FLIP_V_KEY: String = "flip_v"
const _POSITION_KEY: String = "position"
const _ROTATION_KEY: String = "rotation"
const _SCALE_KEY: String = "scale"
const _COLOR_KEY: String = "color"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func from_raw_data(
		raw_data: Variant, project_textures: ProjectTextures
) -> ParseResult:
	var output := ParseResult.new()

	if raw_data is not Array:
		return output
	var raw_array: Array = raw_data

	var decoration_list: Array[WorldDecoration] = []
	for raw_decoration: Variant in raw_array:
		var parse_result: ParseResult = _decoration_from_raw(
				raw_decoration, project_textures
		)
		output.invalid_file_paths.append_array(parse_result.invalid_file_paths)
		decoration_list.append_array(parse_result.decorations.list())

	output.decorations = WorldDecorations.new(decoration_list)
	return output


static func to_raw_array(world_decorations: WorldDecorations) -> Array:
	var output: Array = []

	for world_decoration in world_decorations.list():
		output.append(_decoration_to_raw(world_decoration))

	return output


static func _decoration_from_raw(
		raw_data: Variant, project_textures: ProjectTextures
) -> ParseResult:
	var output := ParseResult.new()

	if raw_data is not Dictionary:
		return output
	var raw_dict: Dictionary = raw_data

	var decoration := WorldDecoration.new()

	# Texture
	if ParseUtils.dictionary_has_number(raw_dict, _TEXTURE_KEY):
		# Id
		var id: int = ParseUtils.dictionary_int(raw_dict, _TEXTURE_KEY)
		project_textures.claim_id(id)
		decoration.texture = TextureFromId.new(id)
	elif ParseUtils.dictionary_has_string(raw_dict, _TEXTURE_KEY):
		# File path
		decoration.texture = TextureFromFilePath.new(
				raw_dict[_TEXTURE_KEY],
				project_textures.project_absolute_path_ref()
		)
	elif ParseUtils.dictionary_has_array(raw_dict, _TEXTURE_KEY):
		# Image data
		decoration.texture = TextureFromImageData.new(raw_dict[_TEXTURE_KEY])

	if ParseUtils.dictionary_has_bool(raw_dict, _FLIP_H_KEY):
		decoration.flip_h = raw_dict[_FLIP_H_KEY]

	if ParseUtils.dictionary_has_bool(raw_dict, _FLIP_V_KEY):
		decoration.flip_v = raw_dict[_FLIP_V_KEY]

	if ParseUtils.dictionary_has_dictionary(raw_dict, _POSITION_KEY):
		var position_dict: Dictionary = raw_dict[_POSITION_KEY]
		if ParseUtils.dictionary_has_number(position_dict, "x"):
			decoration.position.x = (
					ParseUtils.number_as_float(position_dict["x"])
			)
		if ParseUtils.dictionary_has_number(position_dict, "y"):
			decoration.position.y = (
					ParseUtils.number_as_float(position_dict["y"])
			)

	# The rotation is in degrees.
	if ParseUtils.dictionary_has_number(raw_dict, _ROTATION_KEY):
		decoration.rotation_degrees = (
				ParseUtils.number_as_float(raw_dict[_ROTATION_KEY])
		)

	# The scale can be either one number, or a set of x and y.
	if ParseUtils.dictionary_has_number(raw_dict, _SCALE_KEY):
		decoration.scale = (
				Vector2.ONE * ParseUtils.number_as_float(raw_dict[_SCALE_KEY])
		)
	elif ParseUtils.dictionary_has_dictionary(raw_dict, _SCALE_KEY):
		var scale_dict: Dictionary = raw_dict[_SCALE_KEY]
		if ParseUtils.dictionary_has_number(scale_dict, "x"):
			decoration.scale.x = ParseUtils.number_as_float(scale_dict["x"])
		if ParseUtils.dictionary_has_number(scale_dict, "y"):
			decoration.scale.y = ParseUtils.number_as_float(scale_dict["y"])

	if raw_dict.has(_COLOR_KEY):
		decoration.color = ParseUtils.color_from_raw(
				raw_dict[_COLOR_KEY], decoration.color
		)

	output.decorations = WorldDecorations.new([decoration])
	return output


static func _decoration_to_raw(decoration: WorldDecoration) -> Dictionary:
	var output: Dictionary = {}

	# We use an empty decoration to check for default values
	var default_decoration := WorldDecoration.new()

	if decoration.texture.to_raw_data() != null:
		output.merge({ _TEXTURE_KEY: decoration.texture.to_raw_data() })

	if decoration.flip_h != default_decoration.flip_h:
		output.merge({ _FLIP_H_KEY: decoration.flip_h })

	if decoration.flip_v != default_decoration.flip_v:
		output.merge({ _FLIP_V_KEY: decoration.flip_v })

	if decoration.position != default_decoration.position:
		var position_dict: Dictionary = {}
		if decoration.position.x != default_decoration.position.x:
			position_dict.merge({ "x": decoration.position.x })
		if decoration.position.y != default_decoration.position.y:
			position_dict.merge({ "y": decoration.position.y })
		output.merge({ _POSITION_KEY: position_dict })

	if decoration.rotation_degrees != default_decoration.rotation_degrees:
		output.merge({ _ROTATION_KEY: decoration.rotation_degrees })

	if decoration.scale != default_decoration.scale:
		if decoration.scale.x == decoration.scale.y:
			output.merge({ _SCALE_KEY: decoration.scale.x })
		else:
			var scale_dict: Dictionary = {}
			if decoration.scale.x != default_decoration.scale.x:
				scale_dict.merge({ "x": decoration.scale.x })
			if decoration.scale.y != default_decoration.scale.y:
				scale_dict.merge({ "y": decoration.scale.y })
			output.merge({ _SCALE_KEY: scale_dict })

	if decoration.color != default_decoration.color:
		output.merge({ _COLOR_KEY: decoration.color.to_html() })

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

	var decorations := WorldDecorations.new()
