@tool
class_name ItemColor
extends PropertyTreeItem
## A [PropertyTreeItem] that contains a [Color].

signal value_changed(this: PropertyTreeItem)
signal transparency_toggled(this: PropertyTreeItem)

const _DEFAULT_COLOR := Color.WHITE

## Set this property in the inspector to set the default value.
@export var value := _DEFAULT_COLOR:
	set(new_value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		if value != new_value:
			value = new_value
			value_changed.emit(self)

## If true, the value's alpha can be any number.
## Otherwise, the value's alpha is always 1.0,
## in other words, it has no transparency.
@export var is_transparency_enabled: bool = true:
	set(new_value):
		if _is_locked:
			push_warning(_LOCKED_ITEM_MESSAGE)
			return

		if is_transparency_enabled == new_value:
			return

		is_transparency_enabled = new_value

		if is_transparency_enabled:
			value.a = _alpha
		else:
			_alpha = value.a
			value.a = 1.0

		transparency_toggled.emit(self)

var _alpha: float = _DEFAULT_COLOR.a


func get_data() -> Color:
	return value


func set_data(data: Variant) -> void:
	if data is Color:
		value = data
	elif data is String:
		if not data.is_valid_html_color():
			push_warning(
					"Data is an invalid string."
					+ " It must be a valid html color, but it is not."
			)
			return
		value = Color.html(data)
	elif data is Array:
		# The array must have exactly three or four elements,
		# and they must all be a number in the range 0.0 to 1.0.
		var data_array: Array = data

		if data_array.size() != 3 and data_array.size() != 4:
			push_warning("Data is an invalid array. Its size is not 3 or 4.")
			return

		var r: float = 1.0
		var g: float = 1.0
		var b: float = 1.0
		var a: float = 1.0
		if not (
				ParseUtils.is_number(data_array[0])
				and ParseUtils.is_number(data_array[1])
				and ParseUtils.is_number(data_array[2])
				and (
						data_array.size() == 3
						or ParseUtils.is_number(data_array[3])
				)
		):
			push_warning(
					"Data is an invalid array."
					+ " One or more of its elements is not a number."
			)
			return

		r = ParseUtils.number_as_float(data_array[0])
		g = ParseUtils.number_as_float(data_array[1])
		b = ParseUtils.number_as_float(data_array[2])
		if data_array.size() == 4:
			a = ParseUtils.number_as_float(data_array[3])

		if not (
				r >= 0.0 and r <= 1.0
				and g >= 0.0 and g <= 1.0
				and b >= 0.0 and b <= 1.0
				and a >= 0.0 and a <= 1.0
		):
			push_warning(
					"Data is an invalid array. One or more of its elements"
					+ " is not in the range of 0.0 to 1.0."
			)
			return

		value = Color(r, g, b, a)
	else:
		push_warning(_INVALID_TYPE_MESSAGE)
