class_name BitArrayCursor
## A cursor that goes through a [BitArray].[br][br]
## 
## As you take bits at the cursor's location, the cursor
## moves automatically to the next bits in the array.[br]
## Convenient when you don't want your objects to worry
## about where they should be getting data in a [BitArray].


var _bit_cursor: int = 0
var _bit_array: BitArray
var _bits_remaining: int


func _init(bit_array: BitArray) -> void:
	_bit_array = bit_array.copy()
	_bits_remaining = _bit_array.size()


## Returns the number of bits remaining in the array.
func bits_remaining() -> int:
	return _bits_remaining


## Returns the next bits as an int.[br]
## The input number of bits must be a number from 1 to 63 inclusively.[br][br]
## 
## Trying to get bits past the end of the array will cause a crash.[br]
## Please ensure that there are enough
## bits remaining using [method bits_remaining].
func next_bits(number_of_bits: int) -> int:
	var output: int = _bit_array.bits_at(_bit_cursor, number_of_bits)
	_bit_cursor += number_of_bits
	_bits_remaining -= number_of_bits
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
	var byte_array_4: PackedByteArray = [
		0b10000000,
		0,
		0,
		0,
		0b01000101,
		0,
		0,
		0,
	]
	
	var bit_array_1 := BitArray.new(byte_array_1)
	var bit_array_2 := BitArray.new(byte_array_2)
	var bit_array_3 := BitArray.new(byte_array_3)
	var bit_array_4 := BitArray.new(byte_array_4)
	
	var cursor_1 := BitArrayCursor.new(bit_array_1)
	assert(cursor_1.bits_remaining() == 0)
	
	var cursor_2 := BitArrayCursor.new(bit_array_2)
	assert(cursor_2.bits_remaining() == 8)
	assert(cursor_2.next_bits(1) == 1)
	assert(cursor_2.bits_remaining() == 7)
	assert(cursor_2.next_bits(2) == 2)
	assert(cursor_2.bits_remaining() == 5)
	assert(cursor_2.next_bits(3) == 5)
	assert(cursor_2.bits_remaining() == 2)
	assert(cursor_2.next_bits(2) == 3)
	assert(cursor_2.bits_remaining() == 0)
	
	var cursor_3 := BitArrayCursor.new(bit_array_3)
	assert(cursor_3.bits_remaining() == 8 * 7)
	assert(cursor_3.next_bits(9) == 0b101011101)
	assert(cursor_3.bits_remaining() == 47)
	assert(cursor_3.next_bits(3) == 6)
	assert(cursor_3.bits_remaining() == 44)
	assert(cursor_3.next_bits(2) == 3)
	assert(cursor_3.bits_remaining() == 42)
	assert(cursor_3.next_bits(1) == 0)
	assert(cursor_3.bits_remaining() == 41)
	assert(cursor_3.next_bits(8) == 0b10010100)
	assert(cursor_3.bits_remaining() == 33)
	assert(cursor_3.next_bits(1) == 0)
	assert(cursor_3.bits_remaining() == 32)
	assert(cursor_3.next_bits(8) == 0b01011100)
	assert(cursor_3.bits_remaining() == 24)
	assert(cursor_3.next_bits(3) == 1)
	assert(cursor_3.bits_remaining() == 21)
	assert(cursor_3.next_bits(18) == 0b100000111001110001)
	assert(cursor_3.bits_remaining() == 3)
	assert(cursor_3.next_bits(3) == 7)
	assert(cursor_3.bits_remaining() == 0)
	
	var cursor_4 := BitArrayCursor.new(bit_array_3)
	assert(cursor_4.bits_remaining() == 8 * 7)
	assert(cursor_4.next_bits(16) == 0b1010111011101101)
	assert(cursor_4.bits_remaining() == 40)
	assert(cursor_4.next_bits(3) == 0b001)
	assert(cursor_4.bits_remaining() == 37)
	assert(cursor_4.next_bits(37) == 0b0100001011100001100000111001110001111)
	assert(cursor_4.bits_remaining() == 0)
	
	var cursor_5 := BitArrayCursor.new(bit_array_4)
	assert(cursor_5.bits_remaining() == 64)
	# As expected, trying to get 64 bits does not work because of signed int
	#assert(cursor_5.next_bits(64) == 0x8000000045000000)
	#assert(cursor_5.bits_remaining() == 0)
	assert(cursor_5.next_bits(63) == 0x4000000022800000)
	assert(cursor_5.bits_remaining() == 1)
