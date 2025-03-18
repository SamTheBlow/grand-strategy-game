class_name WorldLimitsFromRaw
## Converts raw data into [WorldLimits].
##
## This operation always succeeds.
## Ignores unrecognized data.
## When data is invalid, uses the default value instead.

const WORLD_LIMIT_LEFT_KEY: String = "left"
const WORLD_LIMIT_TOP_KEY: String = "top"
const WORLD_LIMIT_RIGHT_KEY: String = "right"
const WORLD_LIMIT_BOTTOM_KEY: String = "bottom"


static func parsed_from(raw_data: Variant) -> WorldLimits:
	if raw_data is not Dictionary:
		return
	var raw_dict: Dictionary = raw_data

	var left: int = WorldLimits.DEFAULT_LEFT
	if ParseUtils.dictionary_has_number(raw_dict, WORLD_LIMIT_LEFT_KEY):
		left = ParseUtils.dictionary_int(raw_dict, WORLD_LIMIT_LEFT_KEY)

	var top: int = WorldLimits.DEFAULT_TOP
	if ParseUtils.dictionary_has_number(raw_dict, WORLD_LIMIT_TOP_KEY):
		top = ParseUtils.dictionary_int(raw_dict, WORLD_LIMIT_TOP_KEY)

	var right: int = WorldLimits.DEFAULT_RIGHT
	if ParseUtils.dictionary_has_number(raw_dict, WORLD_LIMIT_RIGHT_KEY):
		right = ParseUtils.dictionary_int(raw_dict, WORLD_LIMIT_RIGHT_KEY)

	var bottom: int = WorldLimits.DEFAULT_BOTTOM
	if ParseUtils.dictionary_has_number(raw_dict, WORLD_LIMIT_BOTTOM_KEY):
		bottom = ParseUtils.dictionary_int(raw_dict, WORLD_LIMIT_BOTTOM_KEY)

	return WorldLimits.new().with_values(left, top, right, bottom)
