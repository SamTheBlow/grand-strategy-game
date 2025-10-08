class_name AutoArrowToDict
## Converts an [AutoArrow] into a raw dictionary.
##
## See also: [AutoArrowFromRaw]


static func result(auto_arrow: AutoArrow) -> Dictionary:
	return {
		AutoArrowFromRaw.SOURCE_PROVINCE_ID_KEY:
			auto_arrow.source_province.id,
		AutoArrowFromRaw.DEST_PROVINCE_ID_KEY:
			auto_arrow.destination_province.id,
	}
