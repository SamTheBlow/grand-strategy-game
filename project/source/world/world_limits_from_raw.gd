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
		return WorldLimits.new()
	var raw_dict: Dictionary = raw_data

	var x1: int = WorldLimits.DEFAULT_LEFT
	if ParseUtils.dictionary_has_number(raw_dict, WORLD_LIMIT_LEFT_KEY):
		x1 = ParseUtils.dictionary_int(raw_dict, WORLD_LIMIT_LEFT_KEY)

	var y1: int = WorldLimits.DEFAULT_TOP
	if ParseUtils.dictionary_has_number(raw_dict, WORLD_LIMIT_TOP_KEY):
		y1 = ParseUtils.dictionary_int(raw_dict, WORLD_LIMIT_TOP_KEY)

	var x2: int = WorldLimits.DEFAULT_RIGHT
	if ParseUtils.dictionary_has_number(raw_dict, WORLD_LIMIT_RIGHT_KEY):
		x2 = ParseUtils.dictionary_int(raw_dict, WORLD_LIMIT_RIGHT_KEY)

	var y2: int = WorldLimits.DEFAULT_BOTTOM
	if ParseUtils.dictionary_has_number(raw_dict, WORLD_LIMIT_BOTTOM_KEY):
		y2 = ParseUtils.dictionary_int(raw_dict, WORLD_LIMIT_BOTTOM_KEY)

	return WorldLimits.from_rect2i(Rect2i(x1, y1, x2 - x1, y2 - y1))
