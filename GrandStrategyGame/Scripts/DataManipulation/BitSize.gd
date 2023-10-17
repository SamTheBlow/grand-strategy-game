class_name BitSize
## The size of a number, in bits.


var _value: int


## The number of bits it would take to represent a given number.[br][br]
## 
## The input number must be positive and it must not be zero.[br][br]
## 
## WARNING: may return an incorrect answer for very
## large numbers due to floating-point precision errors.
## To always get the correct number of bits,
## please only input numbers smaller than 140737488355327.
static func of_number(number: int) -> int:
	const INVERSE_LN_2: float = 1.442695040888963407359924681
	return 1 + floori(log(number) * INVERSE_LN_2)


## Always returns a number from 1 to 32 inclusively.
func value() -> int:
	return _value


static func _unit_test() -> void:
	for i in range(1, 47):
		assert(BitSize.of_number((1 << i) - 1) == i)
		assert(BitSize.of_number(1 << i) == i + 1)
