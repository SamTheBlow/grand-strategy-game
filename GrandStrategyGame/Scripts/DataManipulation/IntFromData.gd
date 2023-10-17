class_name IntFromData
## Abstract class for reading an integer from some data structure.


var _value: int


## The read result.
func value() -> int:
	return _value


static func _unit_test() -> void:
	# Nothing to test
	pass
