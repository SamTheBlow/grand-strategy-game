class_name AutoArrowFromRaw
## Converts raw data into an [AutoArrow].
## The game's provinces must be loaded before using this.
##
## See also: [AutoArrowsFromRaw], [AutoArrowToDict]

const SOURCE_PROVINCE_ID_KEY = "source_province_id"
const DEST_PROVINCE_ID_KEY = "destination_province_id"


## This may fail and return null.
static func parsed_from(raw_data: Variant, game: Game) -> AutoArrow:
	if raw_data is not Dictionary:
		return null
	var raw_dict: Dictionary = raw_data

	if not (
			ParseUtils.dictionary_has_number(raw_dict, SOURCE_PROVINCE_ID_KEY)
			and ParseUtils.dictionary_has_number(raw_dict, DEST_PROVINCE_ID_KEY)
	):
		return null

	var source_province_id: int = (
			ParseUtils.dictionary_int(raw_dict, SOURCE_PROVINCE_ID_KEY)
	)
	var source_province: Province = (
			game.world.provinces.province_from_id(source_province_id)
	)
	if source_province == null:
		return null

	var destination_province_id: int = (
			ParseUtils.dictionary_int(raw_dict, DEST_PROVINCE_ID_KEY)
	)
	var destination_province: Province = (
			game.world.provinces.province_from_id(destination_province_id)
	)
	if destination_province == null:
		return null

	return AutoArrow.new(source_province, destination_province)
