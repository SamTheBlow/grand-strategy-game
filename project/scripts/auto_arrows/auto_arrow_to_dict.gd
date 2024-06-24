class_name AutoArrowToDict
## Converts an [AutoArrow] into raw data.


func result(auto_arrow: AutoArrow) -> Dictionary:
	return {
		AutoArrowFromDict.KEY_SOURCE_PROVINCE_ID: (
				auto_arrow.source_province.id
		),
		AutoArrowFromDict.KEY_DESTINATION_PROVINCE_ID: (
				auto_arrow.destination_province.id
		),
	}
