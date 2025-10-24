class_name IntWithSignals
## It's exactly what it says it is.

signal value_changed(new_value: int)

var value: int = 0:
	set(new_value):
		if _cannot_be_negative and new_value < 0:
			push_warning("Tried to set negative value.")
			new_value = 0
		if new_value == value:
			return
		value = new_value
		value_changed.emit(value)

var _cannot_be_negative: bool = false


func _init(starting_value: int = 0, cannot_be_negative: bool = false) -> void:
	value = starting_value
	_cannot_be_negative = cannot_be_negative
