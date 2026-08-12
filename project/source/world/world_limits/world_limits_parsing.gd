class_name WorldLimitsParsing
## Parses raw data from/to [WorldLimits].

const _LIMIT_LEFT_KEY: String = "left"
const _LIMIT_TOP_KEY: String = "top"
const _LIMIT_RIGHT_KEY: String = "right"
const _LIMIT_BOTTOM_KEY: String = "bottom"


## Always succeeds. Ignores unrecognized data.
## When data is invalid, uses the default value instead.
static func load_from_raw_data(
		raw_data: Variant, world_limits: WorldLimits
) -> void:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	var is_empty: bool = true

	var left: int = WorldLimits.DEFAULT_LEFT
	if ParseUtils.dictionary_has_number(raw_dict, _LIMIT_LEFT_KEY):
		left = ParseUtils.dictionary_int(raw_dict, _LIMIT_LEFT_KEY)
		is_empty = false

	var top: int = WorldLimits.DEFAULT_TOP
	if ParseUtils.dictionary_has_number(raw_dict, _LIMIT_TOP_KEY):
		top = ParseUtils.dictionary_int(raw_dict, _LIMIT_TOP_KEY)
		is_empty = false

	var right: int = WorldLimits.DEFAULT_RIGHT
	if ParseUtils.dictionary_has_number(raw_dict, _LIMIT_RIGHT_KEY):
		right = ParseUtils.dictionary_int(raw_dict, _LIMIT_RIGHT_KEY)
		is_empty = false

	var bottom: int = WorldLimits.DEFAULT_BOTTOM
	if ParseUtils.dictionary_has_number(raw_dict, _LIMIT_BOTTOM_KEY):
		bottom = ParseUtils.dictionary_int(raw_dict, _LIMIT_BOTTOM_KEY)
		is_empty = false

	if is_empty:
		return

	world_limits.custom_limits = Vector4i(left, top, right, bottom)
	world_limits.enable_custom_limits()


static func to_raw_data(world_limits: WorldLimits) -> Variant:
	if not world_limits.is_custom_limits_enabled():
		return {}

	var output: Dictionary = {
		_LIMIT_LEFT_KEY: world_limits.custom_limits.x,
		_LIMIT_TOP_KEY: world_limits.custom_limits.y,
		_LIMIT_RIGHT_KEY: world_limits.custom_limits.z,
		_LIMIT_BOTTOM_KEY: world_limits.custom_limits.w,
	}

	if world_limits.custom_limits.x == WorldLimits.DEFAULT_LEFT:
		output.erase(_LIMIT_LEFT_KEY)
	if world_limits.custom_limits.y == WorldLimits.DEFAULT_TOP:
		output.erase(_LIMIT_TOP_KEY)
	if world_limits.custom_limits.z == WorldLimits.DEFAULT_RIGHT:
		output.erase(_LIMIT_RIGHT_KEY)
	if world_limits.custom_limits.w == WorldLimits.DEFAULT_BOTTOM:
		output.erase(_LIMIT_BOTTOM_KEY)

	return output
