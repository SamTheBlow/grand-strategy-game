class_name ArmySize
## Represents the size of an army.
## The size of an army may have a minimum and/or a maximum,
## which this class takes care of.


signal size_changed()
signal reached_zero()
signal became_too_small()
signal became_too_large()

var _size: int
var _minimum_size: int
var _has_maximum_size: bool = false
var _maximum_size: int


## If the maximum size is less than 1, then there is no maximum size.
## 
## Conditions for each input:
## - The starting size must be greater or equal to 1.
## - The starting size must be within the minimum and maximum size.
## - The minimum size must be greater or equal to 1.
## - If there is a maximum size, it must be
##   greater or equal to the minimum size.
func _init(
		starting_size: int = 1,
		minimum_size: int = 1,
		maximum_size: int = 0
) -> void:
	_size = starting_size
	_minimum_size = minimum_size
	_has_maximum_size = maximum_size > 0
	_maximum_size = maximum_size


func current_size() -> int:
	return _size


## Adds some amount of troops. The input must be positive or zero.
func add(number: int) -> void:
	if _has_maximum_size and _size + number > _maximum_size:
		_set_size(_maximum_size)
		became_too_large.emit()
		return
	
	_set_size(_size + number)


## Removes some amount of troops. The input must be positive or zero.
func remove(number: int) -> void:
	var new_size: int = _size - number
	
	if new_size >= _minimum_size:
		_set_size(new_size)
		return
	
	_set_size(_minimum_size)
	if new_size < 1:
		reached_zero.emit()
	became_too_small.emit()
	return


func _set_size(new_size: int) -> void:
	if new_size == _size:
		return
	
	_size = new_size
	size_changed.emit()


func as_JSON() -> int:
	return current_size()


static func _unit_test() -> void:
	var army_size_1 := ArmySize.new(1, 1, 0)
	assert(army_size_1.current_size() == 1)
	army_size_1.remove(69)
	assert(army_size_1.current_size() == 1)
	army_size_1.add(69)
	assert(army_size_1.current_size() == 70)
	
	var army_size_2 := ArmySize.new(14, 10, 100)
	assert(army_size_2.current_size() == 14)
	army_size_2.remove(2)
	assert(army_size_2.current_size() == 12)
	army_size_2.remove(69)
	assert(army_size_2.current_size() == 10)
	army_size_2.add(59)
	assert(army_size_2.current_size() == 69)
	army_size_2.remove(0)
	assert(army_size_2.current_size() == 69)
	army_size_2.add(0)
	assert(army_size_2.current_size() == 69)
	army_size_2.add(1000)
	assert(army_size_2.current_size() == 100)
	army_size_2.remove(3)
	assert(army_size_2.current_size() == 97)
