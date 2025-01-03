class_name AutoArrowsFromRaw
## Converts raw data back into an [AutoArrows] object.
##
## See also: [AutoArrowsToRaw], [AutoArrow]


## Note that the given [Game]'s provinces need to be already loaded.
func result(game: Game, raw_data: Variant) -> AutoArrows:
	var auto_arrows := AutoArrows.new()

	if raw_data is not Array:
		return auto_arrows
	var data_array := raw_data as Array

	for element: Variant in data_array:
		if element is not Dictionary:
			continue

		var data_dict := element as Dictionary
		var new_auto_arrow: AutoArrow = (
				AutoArrowFromDict.new().result(game, data_dict)
		)
		if new_auto_arrow == null:
			continue

		auto_arrows.add(new_auto_arrow)

	return auto_arrows
