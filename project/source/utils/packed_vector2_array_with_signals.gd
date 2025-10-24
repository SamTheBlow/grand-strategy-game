class_name PackedVector2ArrayWithSignals
## It's exactly what it says it is.

signal element_added()
signal element_removed()
signal element_changed()
signal amount_added_to_all(amount_added: Vector2)
## Emitted when any change happens. Emitted last.
signal changed()

## The array is exposed for public access.
## However, editing it from the outside will not emit this object's signals.
var array: PackedVector2Array = []


func _init(starting_array: PackedVector2Array = []) -> void:
	array = starting_array


func append(value: Vector2) -> void:
	array.append(value)
	element_added.emit()
	changed.emit()


func insert(index: int, value: Vector2) -> void:
	array.insert(index, value)
	element_added.emit()
	changed.emit()


func remove_at(index: int) -> void:
	array.remove_at(index)
	element_removed.emit()
	changed.emit()


func change_at(index: int, value: Vector2) -> void:
	array[index] = value
	element_changed.emit()
	changed.emit()


func clear() -> void:
	array.clear()
	element_removed.emit()
	changed.emit()


func add_to_all(add_amount: Vector2) -> void:
	if add_amount == Vector2.ZERO:
		return

	for i in array.size():
		array[i] += add_amount

	element_changed.emit()
	amount_added_to_all.emit(add_amount)
	changed.emit()
