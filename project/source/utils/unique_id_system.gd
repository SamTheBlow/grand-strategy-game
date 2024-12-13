class_name UniqueIdSystem
## Provides unique ids.
## When creating a new unique id, always uses the smallest number available.

## The smallest available number for new ids.
## Negative values are not allowed.
## You can assume that any number smaller than this was already claimed.
var _counter: int = 0
var _claimed_numbers: Array[int] = []

var _smallest_valid_number: int = 0


## If is_zero_valid is set to false, 0 will not be used as a valid id number.
func _init(is_zero_valid: bool = true) -> void:
	if not is_zero_valid:
		_smallest_valid_number = 1

	_counter = _smallest_valid_number


## Returns a new unique id whose number is guaranteed
## to be unique within the scope of this system.
## When is_marked_as_claimed is true, registers the id as unavailable.
## When false, the id still registers as available,
## and it can still be claimed manually later.
func new_unique_id(is_marked_as_claimed: bool = true) -> int:
	# When the counter reaches an already claimed number, skip that number.
	while _claimed_numbers.has(_counter):
		_counter += 1

	if is_marked_as_claimed:
		_claimed_numbers.append(_counter)

	_counter += 1
	return _counter - 1


## Returns an array of new unique ids.
## The array will always be the same size as given number_of_ids.
func new_unique_ids(
		number_of_ids: int, is_marked_as_claimed: bool = true
) -> Array[int]:
	var output: Array[int] = []

	if number_of_ids <= 0:
		return output

	for i in number_of_ids:
		output.append(new_unique_id(is_marked_as_claimed))

	return output


## Returns true if given id is valid and was not already used before.
func is_id_available(id: int) -> bool:
	return is_id_valid(id) and not _claimed_numbers.has(id)


## Returns true if given id is a valid id in this context.
## Note: it doesn't necessarily mean the id will be available for you to use.
func is_id_valid(id: int) -> bool:
	return id >= _smallest_valid_number


## Marks given id as unavailable.
## No effect if the id was already unavailable.
## To know if an id is available, use "is_id_available".
func claim_id(id: int) -> void:
	if is_id_available(id):
		_claimed_numbers.append(id)
