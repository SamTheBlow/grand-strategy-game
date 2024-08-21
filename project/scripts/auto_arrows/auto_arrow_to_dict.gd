class_name AutoArrowToDict
## Converts an [AutoArrow] into a raw dictionary.
##
## See also: [AutoArrowFromDict]


func result(auto_arrow: AutoArrow) -> Dictionary:
	return {
		AutoArrowFromDict.SOURCE_PROVINCE_ID_KEY: (
				auto_arrow.source_province.id
		),
		AutoArrowFromDict.DEST_PROVINCE_ID_KEY: (
				auto_arrow.destination_province.id
		),
	}
