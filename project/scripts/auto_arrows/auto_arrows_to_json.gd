class_name AutoArrowsToJSON
## Converts an [AutoArrows] object into raw data.
## 
## See also: [AutoArrowsFromJSON], [AutoArrow]


func result(auto_arrows: AutoArrows) -> Array:
	var output: Array = []
	for auto_arrow in auto_arrows._list:
		output.append(_auto_arrow_to_dict(auto_arrow))
	return output


func _auto_arrow_to_dict(auto_arrow: AutoArrow) -> Dictionary:
	return {
		AutoArrowsFromJSON.KEY_SOURCE_PROVINCE_ID: (
				auto_arrow.source_province.id
		),
		AutoArrowsFromJSON.KEY_DESTINATION_PROVINCE_ID: (
				auto_arrow.destination_province.id
		),
	}
