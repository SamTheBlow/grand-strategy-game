class_name ProvincesBlueprintFromBinary
extends ProvincesBlueprintFromData
## A provinces blueprint built from a given array of binary data.


# Decorator pattern
var _provinces_blueprint: ProvincesBlueprintFromData


func _init(cursor: BitArrayCursor) -> void:
	# Get the format version
	var uint31_from_bits := UInt31FromBits.new()
	if uint31_from_bits.read(cursor):
		_provinces_blueprint = ProvincesBlueprintFromData.new()
		return
	var format_version: int = uint31_from_bits.value()
	
	# Build according to the format version,
	# or give an error if the version is not supported
	match format_version:
		0:
			_provinces_blueprint = ProvincesBlueprintFromBinaryFormat0.new(cursor)
		_:
			_provinces_blueprint = ProvincesBlueprintFromData.new()
			_provinces_blueprint._error = ParseError.UNSUPPORTED_VERSION
			_provinces_blueprint._version = format_version


static func _unit_test() -> void:
	# Check when the format can't be obtained
	var cursor_1 := BitArrayCursor.new(BitArray.new([0b01000000]))
	var result_1 := ProvincesBlueprintFromBinary.new(cursor_1)
	assert(result_1._provinces_blueprint._error == ParseError.NO_DATA)
	
	# Check when building from a supported format (format 0 in this case)
	var cursor_2 := BitArrayCursor.new(BitArray.new([
		0b00000000, 0b01010000, 0b01000100, 0b11100010, 0b01110110, 
		0b11000001, 0b10000011, 0b10001101, 0b10110110, 0b00000000,
	]))
	var result_2 := ProvincesBlueprintFromBinary.new(cursor_2)
	assert(
			result_2._provinces_blueprint._error == ParseError.OK
			and result_2._provinces_blueprint._version == 0
			and result_2._provinces_blueprint._province_ids
			== PackedInt32Array([0, 1])
			and result_2._provinces_blueprint._province_shapes.size() == 2
	)
	
	# Check when building from an unsupported format
	var cursor_3 := BitArrayCursor.new(BitArray.new([
		0b00110100,
		0b01010000,
	]))
	var result_3 := ProvincesBlueprintFromBinary.new(cursor_3)
	assert(
			result_3._provinces_blueprint._error
			== ParseError.UNSUPPORTED_VERSION
			and result_3._provinces_blueprint._version == 69
	)
