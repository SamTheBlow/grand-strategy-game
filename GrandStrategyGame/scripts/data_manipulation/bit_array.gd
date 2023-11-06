class_name BitArray
## An array of bits.[br]
## Provides tools for working with the
## individual bits inside of a [PackedByteArray].


var _bytes: PackedByteArray


func _init(bytes: PackedByteArray) -> void:
	_bytes = bytes


## Creates a copy of the array, and returns it.
func copy() -> BitArray:
	return BitArray.new(_bytes.duplicate())


## Returns the number of bits in the array.
func size() -> int:
	return _bytes.size() << 3


## Returns a given amount of bits at any given index as an int.[br]
## The input bit index must be a number from 0 to [method size]-1 inclusively.[br]
## The input number of bits must be a number from 1 to 63 inclusively.[br][br]
## 
## Trying to get bits past the end of the array will cause a crash.[br]
## Please ensure that [code]bit_index + number_of_bits <= size()[/code].
func bits_at(bit_index: int, number_of_bits: int) -> int:
	var output: int = 0
	
	var bits_wanted: int = number_of_bits
	while bits_wanted > 0:
		var bits_before_cursor: int = bit_index % 8
		var bits_after_cursor: int = 8 - bits_before_cursor
		
		var bits_to_extract: int
		if bits_after_cursor >= bits_wanted:
			# All the bits we need are in the current byte
			bits_to_extract = bits_wanted
		else:
			# We will also need bits from the next byte
			bits_to_extract = bits_after_cursor
		
		var bits: int = _bytes.decode_u8(bit_index >> 3)
		# Remove the bits to the right of the desired bits
		bits = bits >> (bits_after_cursor - bits_to_extract)
		# Remove the bits to the left of the desired bits
		bits = bits & ((1 << bits_to_extract) - 1)
		
		output = output << bits_to_extract
		output += bits
		
		bit_index += bits_to_extract
		bits_wanted -= bits_to_extract
	
	return output


static func _unit_test() -> void:
	var byte_array_1: PackedByteArray = []
	var byte_array_2: PackedByteArray = [0b11010111]
	var byte_array_3: PackedByteArray = [
		0b10101110,
		0b11101101,
		0b00101000,
		0b01011100,
		0b00110000,
		0b01110011,
		0b10001111,
	]
	
	var bit_array_1 := BitArray.new(byte_array_1)
	assert(bit_array_1.size() == 0)
	
	var bit_array_2 := BitArray.new(byte_array_2)
	assert(bit_array_2.size() == 8)
	assert(bit_array_2.bits_at(1, 4) == 0b1010)
	
	var bit_array_3 := bit_array_2.copy()
	assert(bit_array_3.size() == 8)
	assert(bit_array_3.bits_at(1, 4) == 0b1010)
	
	var bit_array_4 := BitArray.new(byte_array_3)
	assert(bit_array_4.size() == 56)
	assert(bit_array_4.bits_at(0, 6) == 0b101011)
	assert(bit_array_4.bits_at(0, 13) == 0b1010111011101)
	assert(bit_array_4.bits_at(13, 13) == 0b1010010100001)
	assert(bit_array_4.bits_at(12, 5) == 0b11010)
	assert(bit_array_4.bits_at(16, 8) == 0b00101000)
	
	# More testing on bits_at() was done in BitArrayCursor's unit test
