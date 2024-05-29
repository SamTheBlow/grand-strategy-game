class_name ArmySize
## Represents the size of an [Army].
## It may have a minimum and/or a maximum, which this class takes care of.


## Emits whenever the army's size changes.
signal size_changed()
## Emits whenever some piece of code tries to set the army size to a value
## smaller than 1.
signal reached_zero()
## Emits whenever some piece of code tries to set the army size to a value
## smaller than the minimum army size.
signal became_too_small()
## Emits whenever some piece of code tries to set the army size to a value
## larger than the maximum army size, if there is a maximum.
signal became_too_large()

var _size: int:
	set(value):
		if value == _size:
			return
		
		# Respect maximum size
		if _has_maximum_size and value > _maximum_size:
			_size = _maximum_size
			became_too_large.emit()
			size_changed.emit()
			return
		
		# Respect minimum size
		elif value < _minimum_size:
			_size = _minimum_size
			if value < 1:
				reached_zero.emit()
			became_too_small.emit()
			size_changed.emit()
			return
		
		_size = value
		size_changed.emit()

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
	_minimum_size = minimum_size
	_has_maximum_size = maximum_size > 0
	_maximum_size = maximum_size
	_size = starting_size


func current_size() -> int:
	return _size


func minimum() -> int:
	return _minimum_size


## Adds some amount of troops. The input must be positive or zero.
func add(number: int) -> void:
	_size += number


## Removes some amount of troops. The input must be positive or zero.
func remove(number: int) -> void:
	_size -= number


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
