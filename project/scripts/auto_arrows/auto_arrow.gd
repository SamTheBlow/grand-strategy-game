class_name AutoArrow


signal removed()
signal source_province_changed(this: AutoArrow)
signal destination_province_changed(this: AutoArrow)

var source_province: Province:
	set(value):
		var has_changed: bool = source_province != value
		source_province = value
		if has_changed:
			source_province_changed.emit(self)

var destination_province: Province:
	set(value):
		var has_changed: bool = destination_province != value
		destination_province = value
		if has_changed:
			destination_province_changed.emit(self)


func is_equivalent_to(auto_arrow: AutoArrow) -> bool:
	return (
			auto_arrow.source_province == source_province
			and auto_arrow.destination_province == destination_province
	)
