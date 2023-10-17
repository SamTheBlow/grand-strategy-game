class_name Int32FromBits
extends IntFromData
## Reads a signed 32-bit integer from a [BitArrayCursor].


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
	
	# Make sure the array contains all the bits we need
	if cursor.bits_remaining() < bit_size:
		return ERR_PARSE_ERROR
	
	var number: int = cursor.next_bits(bit_size)
	
	# The highest bit represents whether or not it's a negative number
	# (Even if it's just one bit!)
	var highest_bit: int = 1 << bit_size - 1
	var is_negative: bool = number & highest_bit
	if is_negative:
		number = (number & ~highest_bit) - highest_bit
	
	# It worked!
	_value = number
	return OK


static func _unit_test() -> void:
	var int32_from_bits := Int32FromBits.new()
	
	var cursor_1 := BitArrayCursor.new(BitArray.new([]))
	assert(int32_from_bits.read(cursor_1) == ERR_PARSE_ERROR)
	
	var cursor_2 := BitArrayCursor.new(BitArray.new([0b00000000]))
	cursor_2.next_bits(3)
	assert(int32_from_bits.read(cursor_2) == ERR_PARSE_ERROR)
	
	var cursor_3 := BitArrayCursor.new(BitArray.new([0b00000000]))
	assert(
			int32_from_bits.read(cursor_3) == OK
			and int32_from_bits.value() == 0
	)
	
	var cursor_4 := BitArrayCursor.new(BitArray.new([0b00010101]))
	assert(
			int32_from_bits.read(cursor_4) == OK
			and int32_from_bits.value() == -3
	)
	
	var cursor_5 := BitArrayCursor.new(BitArray.new([0b00011101]))
	assert(int32_from_bits.read(cursor_5) == ERR_PARSE_ERROR)
	
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
			int32_from_bits.read(cursor_6) == OK
			and int32_from_bits.value() == -169
	)
	assert(
			int32_from_bits.read(cursor_6) == OK
			and int32_from_bits.value() == -1
	)
	assert(int32_from_bits.read(cursor_6) == ERR_PARSE_ERROR)
