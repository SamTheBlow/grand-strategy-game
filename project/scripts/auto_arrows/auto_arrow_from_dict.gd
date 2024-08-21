class_name AutoArrowFromDict
## Converts raw data back into an [AutoArrow].
##
## See also: [AutoArrowToDict]


const SOURCE_PROVINCE_ID_KEY = "source_province_id"
const DEST_PROVINCE_ID_KEY = "destination_province_id"


## May return null if the data is invalid.
func result(game: Game, data: Dictionary) -> AutoArrow:
	if not (
			ParseUtils.dictionary_has_number(data, SOURCE_PROVINCE_ID_KEY)
			and ParseUtils.dictionary_has_number(data, DEST_PROVINCE_ID_KEY)
	):
		return null
	
	var source_province_id: int = (
			ParseUtils.dictionary_int(data, SOURCE_PROVINCE_ID_KEY)
	)
	var source_province: Province = (
			game.world.provinces.province_from_id(source_province_id)
	)
	if source_province == null:
		return null
	
	var destination_province_id: int = (
			ParseUtils.dictionary_int(data, DEST_PROVINCE_ID_KEY)
	)
	var destination_province: Province = (
			game.world.provinces.province_from_id(destination_province_id)
	)
	if destination_province == null:
		return null
	
	return AutoArrow.new(source_province, destination_province)
