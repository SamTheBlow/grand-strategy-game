class_name AutoArrowsFromJSON
## Converts raw data back into an [AutoArrows] object.
## 
## See also: [AutoArrowsToJSON], [AutoArrow]


const KEY_SOURCE_PROVINCE_ID = "source_province_id"
const KEY_DESTINATION_PROVINCE_ID = "destination_province_id"


## Note that the given [Game]'s provinces need to be already loaded.
func result(game: Game, raw_data: Variant) -> AutoArrows:
	var auto_arrows := AutoArrows.new()
	
	if not (raw_data is Array):
		return auto_arrows
	var data_array := raw_data as Array
	
	for element: Variant in data_array:
		if not (element is Dictionary):
			continue
		var data_dict := element as Dictionary
		var new_auto_arrow: AutoArrow = _auto_arrow_from_dict(game, data_dict)
		if new_auto_arrow == null:
			continue
		auto_arrows.add(new_auto_arrow)
	
	return auto_arrows


## May return null if the data is invalid.
func _auto_arrow_from_dict(game: Game, dictionary: Dictionary) -> AutoArrow:
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
