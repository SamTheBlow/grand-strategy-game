class_name BitSizeFromBits
extends BitSize
## Reads a bit size from a [BitArrayCursor].


## Returns [constant ERR_PARSE_ERROR] if it fails,
## otherwise returns [constant OK].[br]
## Use [method value] to get the result.[br][br]
## 
## Note: this method can be used multiple times without having
## to create a new instance of this object each time.
func read(cursor: BitArrayCursor) -> int:
	const NUMBER_OF_BITS: int = 5
	
	if cursor.bits_remaining() < NUMBER_OF_BITS:
		return ERR_PARSE_ERROR
	
	_value = cursor.next_bits(NUMBER_OF_BITS) + 1
	return OK


static func _unit_test() -> void:
	var bit_size := BitSizeFromBits.new()
	
	var cursor_1 := BitArrayCursor.new(BitArray.new([]))
	assert(bit_size.read(cursor_1) == ERR_PARSE_ERROR)
	
	var cursor_2 := BitArrayCursor.new(BitArray.new([0b00000000]))
	cursor_2.next_bits(5)
	assert(bit_size.read(cursor_2) == ERR_PARSE_ERROR)
	
	var cursor_3 := BitArrayCursor.new(BitArray.new([0b00000000]))
	cursor_3.next_bits(3)
	assert(bit_size.read(cursor_3) == OK and bit_size.value() == 1)
	
	var cursor_4 := BitArrayCursor.new(BitArray.new([0b00010101]))
	assert(bit_size.read(cursor_4) == OK and bit_size.value() == 3)
	
	var cursor_5 := BitArrayCursor.new(BitArray.new([
		0b00011101,
		0b01101001
	]))
	assert(bit_size.read(cursor_5) == OK and bit_size.value() == 4)
	assert(bit_size.read(cursor_5) == OK and bit_size.value() == 22)
	assert(bit_size.read(cursor_5) == OK and bit_size.value() == 21)
	assert(bit_size.read(cursor_5) == ERR_PARSE_ERROR)
