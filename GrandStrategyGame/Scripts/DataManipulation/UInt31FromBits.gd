class_name UInt31FromBits
extends IntFromData
## Reads an unsigned 31-bit integer from a [BitArrayCursor].[br][br]
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
func read(cursor: BitArrayCursor) -> int:
	# The number of bits to look for
	var bit_size_from_bits := BitSizeFromBits.new()
	if bit_size_from_bits.read(cursor) != OK:
		return ERR_PARSE_ERROR
	var bit_size: int = bit_size_from_bits.value()
	
	# The number of bits must not be 32, and
	# make sure the array contains all the bits we need
	if bit_size == 32 or cursor.bits_remaining() < bit_size:
		return ERR_PARSE_ERROR
	
	# It worked!
	_value = cursor.next_bits(bit_size)
	return OK


static func _unit_test() -> void:
	var uint31_from_bits := UInt31FromBits.new()
	
	var cursor_1 := BitArrayCursor.new(BitArray.new([]))
	assert(uint31_from_bits.read(cursor_1) == ERR_PARSE_ERROR)
	
	var cursor_2 := BitArrayCursor.new(BitArray.new([0b00000000]))
	cursor_2.next_bits(3)
	assert(uint31_from_bits.read(cursor_2) == ERR_PARSE_ERROR)
	
	var cursor_3 := BitArrayCursor.new(BitArray.new([0b00000000]))
	assert(
			uint31_from_bits.read(cursor_3) == OK
			and uint31_from_bits.value() == 0
	)
	assert(uint31_from_bits.read(cursor_3) == ERR_PARSE_ERROR)
	
	var cursor_4 := BitArrayCursor.new(BitArray.new([0b00010101]))
	assert(
			uint31_from_bits.read(cursor_4) == OK
			and uint31_from_bits.value() == 5
	)
	
	var cursor_5 := BitArrayCursor.new(BitArray.new([0b00011101]))
	assert(uint31_from_bits.read(cursor_5) == ERR_PARSE_ERROR)
	
	var bit_array_1 := BitArray.new([
		0b01001110,
		0b10101111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11111111,
		0b11110000,
	])
	var cursor_6 := BitArrayCursor.new(bit_array_1)
	assert(
			uint31_from_bits.read(cursor_6) == OK
			and uint31_from_bits.value() == 855
	)
	assert(uint31_from_bits.read(cursor_6) == ERR_PARSE_ERROR)
