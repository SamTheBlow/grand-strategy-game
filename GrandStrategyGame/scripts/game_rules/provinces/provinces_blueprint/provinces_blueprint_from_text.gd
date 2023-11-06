class_name ProvincesBlueprintFromText
extends ProvincesBlueprintFromData
## A provinces blueprint built from a given string of text data.


func _init(data_string: String) -> void:
	var lines: PackedStringArray = data_string.split("\n")
	
	# The format version is on the second line,
	# so make sure there are at least two lines.
	# Also make sure the second line starts with "v"
	if lines.size() < 2 or not lines[1].begins_with("v"):
		_error = ParseError.NO_DATA
		return
	
	var version_text: String = lines[1].erase(0).trim_suffix("\r")
	
	# Make sure the version number is a valid positive 32-bit number
	var uint31_from_string := UInt31FromString.new()
	if uint31_from_string.read(version_text):
		_error = ParseError.NO_DATA
		return
	_version = uint31_from_string.value()
	
	_error = ParseError.UNSUPPORTED_VERSION


static func _unit_test() -> void:
	# Check when there are less than two lines
	var result_1 := ProvincesBlueprintFromText.new("Text: amogus")
	assert(result_1._error == ParseError.NO_DATA)
	
	# Check when the second line doesn't start with a "v"
	var result_2 := ProvincesBlueprintFromText.new("amogus\nsus\namogus")
	assert(result_2._error == ParseError.NO_DATA)
	
	# Check when the version number is invalid
	var result_3 := ProvincesBlueprintFromText.new("\nvSUS")
	assert(result_3._error == ParseError.NO_DATA)
	
	# Check when the version number is valid
	var result_4 := ProvincesBlueprintFromText.new("\nv42069")
	assert(
		result_4._error == ParseError.UNSUPPORTED_VERSION
		and result_4._version == 42069
	)
	
	var result_5 := ProvincesBlueprintFromText.new("\r\nv3\r\namogus\r\n")
	assert(
		result_5._error == ParseError.UNSUPPORTED_VERSION
		and result_5._version == 3
	)
	
	var result_6 := ProvincesBlueprintFromText.new("\nv2147483647")
	assert(
		result_6._error == ParseError.UNSUPPORTED_VERSION
		and result_6._version == 2147483647
	)
