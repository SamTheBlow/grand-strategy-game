class_name Vector2iArrayFromBits
## Reads an array of integer pairs from a [BitArrayCursor].
##
## Note: this implementation only supports positive numbers.


var _array_x: PackedInt32Array = []
var _array_y: PackedInt32Array = []


## Returns [constant ERR_PARSE_ERROR] if it fails,
## otherwise returns [constant OK].[br]
## Use [method value] to get the result.[br][br]
## 
## Note: this method can be used multiple times without having
## to create a new instance of this object each time.
func read(cursor: BitArrayCursor) -> int:
	# The array size (must not be 0)
	var uint31_from_bits := UInt31FromBits.new()
	if uint31_from_bits.read(cursor) or uint31_from_bits.value() == 0:
		return ERR_PARSE_ERROR
	var array_size: int = uint31_from_bits.value()
	
	# The number of bits to look for (must not be 32)
	var bit_size_from_bits := BitSizeFromBits.new()
	if bit_size_from_bits.read(cursor) or bit_size_from_bits.value() == 32:
		return ERR_PARSE_ERROR
	var bit_size: int = bit_size_from_bits.value()
	
	# Make sure the array contains all the data
	var total_bit_size: int = (bit_size << 1) * array_size
	if cursor.bits_remaining() < total_bit_size:
		return ERR_PARSE_ERROR
	
	# We're ready to read all the data
	_array_x = []
	_array_y = []
	for i in array_size:
		_array_x.append(cursor.next_bits(bit_size))
		_array_y.append(cursor.next_bits(bit_size))
	return OK


## The x component of the read values.[br]
## Has no meaning if an error occured.[br][br]
## 
## WARNING: returns a reference to the
## original array, for performance reasons.
func values_x() -> PackedInt32Array:
	return _array_x


## The y component of the read values.[br]
## Has no meaning if an error occured.[br][br]
## 
## WARNING: returns a reference to the
## original array, for performance reasons.
func values_y() -> PackedInt32Array:
	return _array_y


static func _unit_test() -> void:
	var vector2i_array_from_bits := Vector2iArrayFromBits.new()
	
	var cursor_1 := BitArrayCursor.new(BitArray.new([]))
	assert(vector2i_array_from_bits.read(cursor_1) == ERR_PARSE_ERROR)
	
	var cursor_2 := BitArrayCursor.new(BitArray.new([
		0b00000000,
		0b00000000
	]))
	assert(vector2i_array_from_bits.read(cursor_2) == ERR_PARSE_ERROR)
	
	var cursor_3 := BitArrayCursor.new(BitArray.new([
		0b00000100,
		0b00001000
	]))
	assert(
			vector2i_array_from_bits.read(cursor_3) == OK
			and vector2i_array_from_bits.values_x() == PackedInt32Array([0])
			and vector2i_array_from_bits.values_y() == PackedInt32Array([1])
	)
	assert(vector2i_array_from_bits.read(cursor_3) == ERR_PARSE_ERROR)
	
	var cursor_4 := BitArrayCursor.new(BitArray.new([
		0b00101001,
		0b01000011,
		0b01001001, 0b10110000, 0b10010110, 0b00100001, 0b00000010,
		0b01100111, 0b00011000, 0b00010000, 0b11001011, 0b00111110,
	]))
	var answer_x := PackedInt32Array([
		4, 11, 9, 2, 0, 6, 1, 1, 12, 3,
	])
	var answer_y := PackedInt32Array([
		9, 0, 6, 1, 2, 7, 8, 0, 11, 14,
	])
	assert(
			vector2i_array_from_bits.read(cursor_4) == OK
			and vector2i_array_from_bits.values_x() == answer_x
			and vector2i_array_from_bits.values_y() == answer_y
	)
	assert(vector2i_array_from_bits.read(cursor_4) == ERR_PARSE_ERROR)
	
	# Make sure a bit size of 32 for array data gives an error
	var cursor_5 := BitArrayCursor.new(BitArray.new([
		0b01110000,
		0b00000000,
		0b01011111,
		0b00000000, 0b00000000, 0b00000000, 0b00000000,
		0b00000000, 0b00000000, 0b00000000, 0b00000000,
	]))
	assert(vector2i_array_from_bits.read(cursor_5) == ERR_PARSE_ERROR)
