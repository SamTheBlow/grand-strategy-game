class_name StringRef
## A [String] passed by reference.
## Emits a signal when the value changes.

signal changed()

var value: String:
	set(new_value):
		if value == new_value:
			return
		value = new_value
		changed.emit()


func _init(starting_value: String = "") -> void:
	value = starting_value
