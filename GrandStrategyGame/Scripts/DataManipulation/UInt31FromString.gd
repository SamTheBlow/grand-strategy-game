class_name UInt31FromString
extends IntFromData
## Reads an unsigned 31-bit integer from a [String].[br][br]
## 
## Unsigned 31-bit integers can be convenient,
## for example, when working with a PackedInt32Array
## which only works with signed 32-bit integers.


## Returns [constant ERR_PARSE_ERROR] if it fails,
## otherwise returns [constant OK].[br]
## Use [method value] to get the result.[br][br]
## 
## Note: this method can be used multiple times without having
## to create a new instance of this object each time.
func read(string: String) -> int:
	if (
			# The string must only contain digits
			not string.is_valid_int()
			or "+" in string
			or "-" in string
			# The string must not have any leading zeroes
			or string.length() > 1 and string[0] == "0"
	):
		return ERR_PARSE_ERROR
	
	# The number must not be too large (within the bounds of int)
	const MAX_NUMBER: String = "9223372036854775807"
	if string.length() > 19:
		return ERR_PARSE_ERROR
	elif string.length() == 19:
		for i in 19:
			var delta: int = string[i].to_int() - MAX_NUMBER[i].to_int()
			if delta > 0:
				return ERR_PARSE_ERROR
			elif delta < 0:
				break
	
	var result: int = string.to_int()
	
	# The value must fit inside a 32-bit integer
	if result > 0x7FFFFFFF:
		return ERR_PARSE_ERROR
	
	_value = result
	return OK


static func _unit_test() -> void:
	# Check when the string is empty
	assert(UInt31FromString.new().read("") == ERR_PARSE_ERROR)
	
	# Check when the string contains characters other than digits
	assert(UInt31FromString.new().read("SUS") == ERR_PARSE_ERROR)
	assert(UInt31FromString.new().read("0a1b2c") == ERR_PARSE_ERROR)
	assert(UInt31FromString.new().read("+60") == ERR_PARSE_ERROR)
	assert(UInt31FromString.new().read("6+0") == ERR_PARSE_ERROR)
	assert(UInt31FromString.new().read("-72") == ERR_PARSE_ERROR)
	assert(UInt31FromString.new().read("3.14159") == ERR_PARSE_ERROR)
	
	# Check when there are leading zeroes
	assert(UInt31FromString.new().read("00069") == ERR_PARSE_ERROR)
	
	# Check when the number is too large
	assert(UInt31FromString.new().read("2147483648") == ERR_PARSE_ERROR)
	assert(
			UInt31FromString.new().read("12345678901234567890")
			== ERR_PARSE_ERROR
	)
	assert(
			UInt31FromString.new().read("9223372036864775807")
			== ERR_PARSE_ERROR
	)
	
	# Check when it should work
	var uint31_from_string := UInt31FromString.new()
	assert(
		uint31_from_string.read("0") == OK
		and uint31_from_string.value() == 0
	)
	assert(
		uint31_from_string.read("110") == OK
		and uint31_from_string.value() == 110
	)
	assert(
		uint31_from_string.read("690690690") == OK
		and uint31_from_string.value() == 690690690
	)
	assert(
		uint31_from_string.read("2147483647") == OK
		and uint31_from_string.value() == 2147483647
	)
