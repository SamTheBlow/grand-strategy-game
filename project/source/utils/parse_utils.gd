class_name ParseUtils
## Provides utility functions for parsing from/to raw data.
# CAUTION
# The built-in JSON parser converts all integers into floats.
# So any number loaded from JSON data will be a float, not an int.
# One important implication of this is that extremely large integer numbers
# will lose precision when they are converted to floats.
# For example, if you try to save the number 3162759323876435874 to JSON,
# the parser will convert it to a float and it will become 3162759323876435968.
# It is up to you to prevent precision errors
# (i.e. don't save extremely large numbers directly as integers).
# One way to do it is by saving the number as a [String].
# This class will consider it a valid number and convert it to an integer.


## Returns true if given dictionary has given key and its value is a number.
static func dictionary_has_number(dictionary: Dictionary, key: String) -> bool:
	return dictionary.has(key) and is_number(dictionary[key])


## Returns the value associated with given key in given dictionary,
## parsed as an int. This may crash the game! Make sure that the dictionary
## has the key and that it's indeed a number, using dictionary_has_number.
static func dictionary_int(dictionary: Dictionary, key: String) -> int:
	return number_as_int(dictionary[key])


## Returns the value associated with given key in given dictionary,
## parsed as a float. This may crash the game! Make sure that the dictionary
## has the key and that it's indeed a number, using dictionary_has_number.
static func dictionary_float(dictionary: Dictionary, key: String) -> float:
	return number_as_float(dictionary[key])


## Returns true if given dictionary has given key and its value is a boolean.
static func dictionary_has_bool(dictionary: Dictionary, key: String) -> bool:
	return dictionary.has(key) and dictionary[key] is bool


## Returns true if given dictionary has given key and its value is a string.
static func dictionary_has_string(dictionary: Dictionary, key: String) -> bool:
	return dictionary.has(key) and dictionary[key] is String


## Returns true if given dictionary has given key and its value is an array.
static func dictionary_has_array(dictionary: Dictionary, key: String) -> bool:
	return dictionary.has(key) and dictionary[key] is Array


## Returns the value associated with given key in given dictionary, parsed
## as an Array[int]. This may crash the game! Make sure that the dictionary
## has the key and that it's indeed an array, with dictionary_has_array.
static func dictionary_array_int(
		dictionary: Dictionary, key: String
) -> Array[int]:
	return array_typed_int(dictionary[key])


## Returns true if given dictionary has given key
## and its value is a dictionary.
static func dictionary_has_dictionary(
		dictionary: Dictionary, key: String
) -> bool:
	return dictionary.has(key) and dictionary[key] is Dictionary


## Takes an untyped array and returns a typed array of type int.
## For each of the array's elements, converts it into an int if it's a number
## (see is_number), otherwise discards the element.
## Do not assume the resulting array will be the same size!
static func array_typed_int(array: Array) -> Array[int]:
	var output: Array[int] = []
	for element: Variant in array:
		if is_number(element):
			output.append(number_as_int(element))
	return output


## Returns true if given [Variant] is either an [int], a [float],
## or a [String] that is a valid [int] or [float].
static func is_number(variant: Variant) -> bool:
	match typeof(variant):
		TYPE_INT, TYPE_FLOAT:
			return true
		TYPE_STRING:
			var string := variant as String
			return string.is_valid_int() or string.is_valid_float()
		_:
			return false


## Returns the given number parsed as an int.
## Consider using is_number first to make sure it's a number.
static func number_as_int(variant: Variant) -> int:
	match typeof(variant):
		TYPE_INT:
			return variant
		TYPE_FLOAT:
			return roundi(variant)
		TYPE_STRING:
			var string := variant as String
			if string.is_valid_int():
				return string.to_int()
			elif string.is_valid_float():
				return number_as_int(string.to_float())

	push_error("That's not a valid number!")
	return 0


## Returns the given number parsed as a float.
## Consider using is_number first to make sure it's a number.
static func number_as_float(variant: Variant) -> float:
	match typeof(variant):
		TYPE_INT:
			return float(variant)
		TYPE_FLOAT:
			return variant
		TYPE_STRING:
			var string := variant as String
			if string.is_valid_int():
				return number_as_float(string.to_int())
			elif string.is_valid_float():
				return string.to_float()

	push_error("That's not a valid number!")
	return 0.0


## Returns true if given [Variant] is an empty [Array].
static func is_empty_array(variant: Variant) -> bool:
	return variant is Array and variant.is_empty()


## Returns true if given [Variant] is an empty [Dictionary].
static func is_empty_dict(variant: Variant) -> bool:
	return variant is Dictionary and variant.is_empty()


## Converts given [Variant] into a [Color], if possible.
## If it fails, returns given fallback color instead.
static func color_from_raw(raw_data: Variant, fallback_color: Color) -> Color:
	if raw_data is not String:
		return fallback_color
	var data_string: String = raw_data

	if not Color.html_is_valid(data_string):
		return fallback_color

	return Color.html(data_string)
