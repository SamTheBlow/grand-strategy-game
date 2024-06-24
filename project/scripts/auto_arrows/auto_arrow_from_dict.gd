class_name AutoArrowFromDict
## Converts raw data back into an [AutoArrow].


const KEY_SOURCE_PROVINCE_ID = "source_province_id"
const KEY_DESTINATION_PROVINCE_ID = "destination_province_id"


## May return null if the data is invalid.
func result(game: Game, dictionary: Dictionary) -> AutoArrow:
	if not (
			dictionary.has(KEY_SOURCE_PROVINCE_ID)
			and dictionary.has(KEY_DESTINATION_PROVINCE_ID)
	):
		return null
	
	var source_data: Variant = dictionary[KEY_SOURCE_PROVINCE_ID]
	var source_province_id: int
	if source_data is int:
		source_province_id = source_data
	elif source_data is float:
		source_province_id = roundi(source_data)
	else:
		return null
	
	var destination_data: Variant = dictionary[KEY_DESTINATION_PROVINCE_ID]
	var destination_province_id: int
	if destination_data is int:
		destination_province_id = destination_data
	elif destination_data is float:
		destination_province_id = roundi(destination_data)
	else:
		return null
	
	var source_province: Province = (
			game.world.provinces.province_from_id(source_province_id)
	)
	if source_province == null:
		return null
	
	var destination_province: Province = (
			game.world.provinces.province_from_id(destination_province_id)
	)
	if destination_province == null:
		return null
	
	var auto_arrow := AutoArrow.new()
	auto_arrow.source_province = source_province
	auto_arrow.destination_province = destination_province
	return auto_arrow
