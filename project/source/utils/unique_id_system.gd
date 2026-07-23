class_name UniqueIdSystem
## Provides unique ids.
## When creating a new unique id, always uses the smallest number available.

## The smallest available number for new ids.
## Negative values are not allowed.
## You can assume that all numbers smaller than this
## are already in use or were reserved for future use.
var _counter: int = 0

## A list of all the ids that are currently in use.
## Just because a unique id has been given out,
## doesn't necessarily mean that it's being used.
var _used_numbers: Array[int] = []

var _smallest_valid_number: int = 0


## If is_zero_valid is set to false, 0 will not be used as a valid id number.
func _init(is_zero_valid: bool = true) -> void:
	if not is_zero_valid:
		_smallest_valid_number = 1

	_counter = _smallest_valid_number


## Returns a new unique id whose number is guaranteed
## to be unique within the scope of this system.
## If is_used is true, marks the id as being in use.
## Otherwise, the id is still available for later use.
## Either way, output id will never be given out by this function again.
func new_unique_id(is_used: bool = true) -> int:
	# When the counter reaches an already in use number, skip that number.
	while _used_numbers.has(_counter):
		_counter += 1

	if is_used:
		_used_numbers.append(_counter)

	_counter += 1
	return _counter - 1


## Returns an array of new unique ids.
## The array will always be the same size as given number_of_ids.
func new_unique_ids(number_of_ids: int, is_used: bool = true) -> Array[int]:
	var output: Array[int] = []

	if number_of_ids <= 0:
		return output

	for i in number_of_ids:
		output.append(new_unique_id(is_used))

	return output


## Returns true if given id is valid and not currently in use.
func is_id_available(id: int) -> bool:
	return is_id_valid(id) and not _used_numbers.has(id)


## Returns true if given id is a valid id in this context.
## Note: it doesn't necessarily mean the id will be available for you to use.
func is_id_valid(id: int) -> bool:
	return id >= _smallest_valid_number


## Marks given id as being in use.
## No effect if the id was already unavailable.
## To know if an id is available, use "is_id_available".
func claim_id(id: int) -> void:
	if is_id_available(id):
		_used_numbers.append(id)


## Marks given id as no longer being in use.
## It becomes available for use and can be claimed again.
## However, it remains a reserved number, meaning
## it will never be given out as a new unique id.
## No effect if given id was already not in use.
func unclaim_id(id: int) -> void:
	_used_numbers.erase(id)
