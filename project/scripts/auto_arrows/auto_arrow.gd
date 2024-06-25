class_name AutoArrow
## Represents a movement from a source [Province] to a destination [Province].
## This is (kind of) a struct: two autoarrows with the same properties
## should be considered the same autoarrow.
## Also, the properties are not meant to be changed, ever.


var source_province: Province:
	set(value):
		if source_province == null:
			source_province = value
			return
		push_warning("Tried to change an AutoArrow's source province.")

var destination_province: Province:
	set(value):
		if destination_province == null:
			destination_province = value
			return
		push_warning("Tried to change an AutoArrow's destination province.")


func is_equivalent_to(auto_arrow: AutoArrow) -> bool:
	return (
			auto_arrow.source_province == source_province
			and auto_arrow.destination_province == destination_province
	)
